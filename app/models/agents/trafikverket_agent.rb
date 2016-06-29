require "date"
require "active_support/time"
require "json"
require 'net/http'
require 'slack-notifier'
require 'digest/md5'

module Agents
  class TrafikverketAgent < Agent
    default_schedule "every_5m"
    description <<-MD
    	Agent för omvandling av data från Trafikverkets öppna API till nyhetsartiklar.
    	Tar emot data via en POST-request och returnerar ett JSON-objekt.
    MD
    event_description <<-MD
      fylls i när strukturen som passar OC är känd.

      Annars ser den ut så här just nu:
      {article:{
        :systemversion:,
        :id,
        :point,
        :lat,
        :long,
        :poly,
        :prio,
        :rubrik,
        :omr,
        :ingress,
        :brodtext
        :exact_poly,
        }
      }
      MD

    def default_options
      { "url_string" => "http://api.trafikinfo.trafikverket.se/v1.1/data.json",
      	"api_key" => "984fb975e4c540ccae03ec5558b2e657" }
    end

    def validate_options
      errors.add(:base, "url_string is required") unless options['url_string'].present?
      errors.add(:base, "api_key is required") unless options['api_key'].present?
    end

    def valid_alert?(m)
      @need = ['MessageCodeValue', 'SeverityCode', 'VersionTime', 'LocationDescriptor', 'Message', 'CountyNo', 'Geometry', 'MessageType']
      @useful = ['RoadNumber', 'EndTime']
      # Filtrerar bort poster som inte är ursprungsposter
      if m.has_key?('EndTime')
        return false if DateTime.parse(m['EndTime']).today? == false 
      end
      return false if DateTime.parse(m['StartTime']).today? == false
      return false if m['ManagedCause'] != true 
      return false if m['CreationTime'] < m['StartTime']
      return false if DateTime.parse(m['CreationTime']).today? == false
      # Filtrerar bort ofullständiga poster 
      return false if (m.keys & @need).length < 8
      # Filtrerar bort allt utom systemversion 1
      return false if m['Id'][15] != "1"
        # Här borde det finnas en slack output
        # p m['Id']
      # Filtrerar bort allt med prio mindre än 4
      return false if m[@need[1]] < 4
      # p "gått igenom: #{m['Id']}, #{m[@need[0]]}"
      return true
    end

    def roadwork_repeat(m)
      if m[@need[0]] == "roadworks" || m[@need[0]] == "resurfacingWork"
        return false
      else
        return true
      end
    end

    def filter_and_text
      # redis.flushall
      data = Agents::TRAFIKVERKET::POST.post_call(options['url_string'], @post_body)
      lan = []
      res = {articles:[]}
      data['RESPONSE']['RESULT'][0]['Situation'].each do |d|
        d['Deviation'].each do |m|
          article = {}
          geometry = {}
          info = []
          next unless valid_alert?(m)
          next unless roadwork_repeat(m)
          article[:Trafikverket_agent_version] = "1.0"
          article[:generated_at] = Time.now
          article[:title] = headline_place(build_headline(m), m)
          article[:ort] = lansomv(m)
          article[:ingress] = rensa_fel(build_ingress(m))
          article[:body] = rensa_fel(build_brodtext(m))
          article[:priority] = m[@need[1]]
          article[:udid] = m['Id'] # unikt id för situationen
          article[:uid] = d['Id'] # unikt deviation-id
          @need.each do |i|
            info << m[i]
          end
          article[:info] = info
          article[:tags] = ['id': 'some_number', 'name': 'Trafikverket', 'type': m[@need[7]]]
          article[:categories] = ['id': 'some_number', 'name': 'Trafikvarning']
          geometry[:lat] = m[@need[6]]['WGS84'].split[2][0..-2]
          geometry[:long] = m[@need[6]]['WGS84'].split[1][1..-1]
          article[:data_created_at] = m['CreationTime']
          article[:version_time] = m['VersionTime']
          article[:geometry] = geometry
          digest = checksum("#{article[:udid]}")
          next if digest == redis.get(article[:udid])
          res[:articles] << article
          redis.set(article[:udid], digest)
          # slacking(article)
          @article_counter = redis.incr("Trafikverket_article_count")
          slack(m, article)
          slacka(m, article)
        end
      end
      if res[:articles].length > 0 then create_event payload: res end
      return res
  	end

    def build_headline(m)
      rubrik = Agents::TRAFIKVERKET::Tv::RUBRIKER[Agents::TRAFIKVERKET::Tv::PRIONIV[m['SeverityCode']]][Agents::TRAFIKVERKET::Tv::LEVEL[m['MessageCodeValue']]]
      if rubrik.nil?
        # Här borde skickas felmeddelande till Slackkanal mded följande info: p m[@need[0]] + m[@need[4]]
        rubrik = "Trafikverket går ut med varning till allmänheten"
      end
      return rubrik
    end

    def build_ingress(m)
        "#{Agents::TRAFIKVERKET::Tv::BESKR[m[@need[0]]]} orsakar problem i trafiken på #{m[@need[3]]}."
    end

    def build_brodtext(m)
      meddelande = m[@need[4]]
      versionstid = DateTime.parse(m[@need[2]])
      dag = Agents::TRAFIKVERKET::Tv::DAGAR[versionstid.wday]
      if not m[@useful[1]].nil?
        sluttid = DateTime.parse(m[@useful[1]])
      else
        sluttid = versionstid
      end
      "Trafikverket rapporterar störningar i trafiken #{update_headline("", m)}och orsaken är #{enett(m)}#{meddelande[1..-1].gsub("\r\n", "").gsub("\n", "")}. Det hela påverkar #{m[@need[3]]}.
Varningen gick ut på #{dag} klockan #{DateTime.parse(m['CreationTime']).strftime("%R")}. #{sluttid_n(versionstid, sluttid)}"
    end

    def enett(m)
      type = m[@need[4]].split
      if Agents::TRAFIKVERKET::Tv::ENETT[type[0].gsub(".", "").downcase].nil?
        type[0][0].downcase    
      else
        Agents::TRAFIKVERKET::Tv::ENETT[type[0].gsub(".", "").downcase]
      end
    end

    def sluttid_n(version, slut)
    	if slut > DateTime.now
        if slut.day != version.day
          "Man beräknar att trafiken kommer påverkas fram till #{Agents::TRAFIKVERKET::Tv::DAGAR[slut.wday]} den #{slut.day} #{Agents::TRAFIKVERKET::Tv::MANAD[slut.month]} klockan #{slut.strftime("%R")}."
        else
          "Man beräknar att trafiken kommer påverkas fram till klockan #{slut.strftime("%R")}."
        end
    	else
        ""
    	end
    end

    def update_headline(rubrik, m)
      if not m['RoadNumber'].nil?
        if m['RoadNumber'][0] == "E"
          "#{rubrik} på #{m['RoadNumber'].split[0]}#{m['RoadNumber'].split[1]}"
        elsif m['RoadNumber'] == "Väg 6"
          "#{rubrik} på E6"
        else
          "#{rubrik} på #{m['RoadNumber'].downcase}"
        end
      else
        rubrik
      end
    end

    def headline_place(rubrik, m)
      place = m['LocationDescriptor'].gsub("Cirkulationsplats ", "")
                         .gsub("Trafikplats ", "")
                         .gsub("Länsgräns ", "")
                         .gsub("Tpl ", "")
                         .gsub("Länsgr. ", "")
                         .gsub("Motorbana", "motorbana")
                         .gsub(/\([^()]*\)/, "")
                         .gsub(/\[[^()]*\]/, "")
                         .gsub("  ", " ")
                       
      from_position = []
      three_word_place = place.match(/(från|mellan)\s([A-ZÅÄÖ][a-zåäö]+)\s([A-ZÅÄÖ][a-zåäö]+)\s([A-ZÅÄÖ][a-zåäö]+)/)
      three_word_to = place.match(/(till|och|vid)\s([A-ZÅÄÖ][a-zåäö]+)\s([A-ZÅÄÖ][a-zåäö]+)\s([A-ZÅÄÖ][a-zåäö]+)/)
      two_word_place = place.match(/(från|mellan)\s([A-ZÅÄÖ][a-zåäö]+)\s([A-ZÅÄÖ][a-zåäö]+)/)
      two_word_to = place.match(/(till|och|vid)\s([A-ZÅÄÖ][a-zåäö]+)\s([A-ZÅÄÖ][a-zåäö]+)/)
      from_place = place.match(/(från|mellan)\s([A-ZÅÄÖ][a-zåäö]+)/)
      to_place = place.match(/(till|och|vid)\s([A-ZÅÄÖ][a-zåäö]+)/)
      at_place = place.match(/(vid)\s([A-ZÅÄÖ][a-zåäö]+)/)
      
      if three_word_place.nil? == false
        if three_word_to
          # p "three"
          if "#{three_word_place[2]} #{three_word_place[3]} #{three_word_place[4]}" == "#{three_word_to[2]} #{three_word_to[3]} #{three_word_to[4]}"
            return "#{update_headline(rubrik, m)} vid #{three_word_place[2]} #{three_word_place[3]} #{three_word_place[4]}"
          else
            return "#{update_headline(rubrik, m)} mellan #{three_word_place[2]} #{three_word_place[3]} #{three_word_place[4]} och #{three_word_to[2]} #{three_word_to[3]} #{three_word_to[4]}"
          end
        elsif two_word_to
          return "#{update_headline(rubrik, m)} mellan #{three_word_place[2]} #{three_word_place[3]} #{three_word_place[4]} och #{two_word_to[2]} #{two_word_to[3]}"
        elsif to_place
          return "#{update_headline(rubrik, m)} mellan #{three_word_place[2]} #{three_word_place[3]} #{three_word_place[4]} och #{to_place[2]}"
        else
          update_headline(rubrik, m)
        end
      elsif two_word_place.nil? == false
        # p "två"
        if three_word_to 
          return "#{update_headline(rubrik, m)} mellan #{two_word_place[2]} #{two_word_place[3]} och #{three_word_to[2]} #{three_word_to[3]} #{three_word_to[4]}"
        elsif two_word_to
          if "#{two_word_place[2]} #{two_word_place[3]}" == "#{two_word_to[2]} #{two_word_to[3]}"
            return "#{update_headline(rubrik, m)} vid #{two_word_place[2]} #{two_word_place[3]}"
          else
            return "#{update_headline(rubrik, m)} mellan #{two_word_place[2]} #{two_word_place[3]} och #{two_word_to[2]} #{two_word_to[3]}"
          end
        elsif to_place
          return "#{update_headline(rubrik, m)} mellan #{two_word_place[2]} #{two_word_place[3]} och #{to_place[2]}"
        else
          update_headline(rubrik, m)
        end
      elsif from_place.nil? == false
        # p "hejsan!"
        if three_word_to
          return "#{update_headline(rubrik, m)} mellan #{from_place[2]} och #{three_word_to[2]} #{three_word_to[3]} #{three_word_to[4]}"
        elsif two_word_to
          return "#{update_headline(rubrik, m)} mellan #{from_place[2]} och #{two_word_to[2]} #{two_word_to[3]}"
        elsif to_place.nil? == false
          if from_place[2] == to_place[2]
            return "#{update_headline(rubrik, m)} vid #{to_place[2]}"
          else
            return "#{update_headline(rubrik, m)} mellan #{from_place[2]} och #{to_place[2]}"
          end
        else  
        update_headline(rubrik, m)
        end
      elsif at_place.nil? == false
        if at_place[2][-1] == ","
          return "#{update_headline(rubrik, m)} vid #{at_place[2][0..-2]}"
        else
          return "#{update_headline(rubrik, m)} vid #{at_place[2]}"
        end
      else
        update_headline(rubrik, m)
      end
    end

    def lansomv(m)
      list = []
      lan = m[@need[5]]
      for lansnr in lan
          if lansnr == 2
            next
          else
            list.push(Agents::TRAFIKVERKET::Tv::LANSNUMMER[lansnr])
            if list.length > 1
              ort = list[0..-2].join(", ") + " och " + list[-1]
            else
              ort = list[0]
            end
          end
      	end
      return ort
    end

    def rensa_fel(text)
      text = text
        .gsub(/\([^()]*\)/, "") # Reg ex för att rensa paranteser och data däri
        .gsub("  ", " ")
        .gsub(" .", ".")
        .gsub(" , ", ", ")
        .gsub(".'.", "'.")
        .gsub("..", ".")
        .gsub(".,", ",")
        .gsub(" . ", ". ")
        .gsub(" '.", "'.")
        .gsub("jvstn", "järnvägsstation")
        .gsub("Tpl", "Trafikplats")
        .gsub("Länsgräns AB/C", "länsgränsen mellan Stockholm och Uppsala")
        .gsub("Länsgräns U/W", "länsgränsen mellan Dalarna och Västmanland")
        .gsub(" S ", " södra ")
        .gsub(" N ", " norra ")
        .gsub(" Ö ", " östra ")
        .gsub(" V ", " västra ")
        .gsub("automatiskt kömeddelande : I riktning (N)       .", "långa köer i nordlig riktning")
        .gsub("automatiskt kömeddelande : I riktning (S)       .", "långa köer i sydlig riktning")
        .gsub("automatiskt kömeddelande : I riktning (Ö)       .", "långa köer i östlig riktning")
        .gsub("automatiskt kömeddelande : I riktning (V)       .", "långa köer i västlig riktning")
        .gsub("automatiskt kömeddelande : I riktning ", "långa köer")
        .gsub(" - ", "-")
        .gsub("/1", " januari")
        .gsub("/2", " februari")
        .gsub("/3", " mars")
        .gsub("/4", " april")
        .gsub("/5", " maj")
        .gsub("/6", " juni")
        .gsub("/7", " juli")
        .gsub("/8", " augusti")
        .gsub("/9", " september")
        .gsub("/10", " oktober")
        .gsub("/11", " november")
        .gsub("/12", " december")
        .gsub(/(\d\d):(\d\d)/, '\1.\2')
        .gsub(/(\d+)([\a-zåäöÅÄÖ]+)/, '\1 \2')
        .gsub(/(\D)\.(\S)/, '\1. \2')
        .gsub("Gävlei", "Gävle i")
        .gsub("\r\n", "")
        .gsub("en händelse som och det som", "en händelse som")
        .gsub(/(E) (\d+)/, '\1\2')
        .gsub("km/h", "kilometer i timmen")
        .gsub(/\[[^()]*\]/, "")
        .gsub(/(E\d{1,2})(.)(\d{2,3})/, '\1')
        .gsub(/(E\d{1,2}) (.) (\d{2,3})/, '\1')
        .gsub("Lednings/telearb.", "lednings- och telearbete")
        .gsub("pga", "på grund av")
        .gsub("Väg", "väg")
        .gsub("Länsgräns AB/D", "länsgränsen mellan Stockholm och Södermanland")
        .gsub("jord/Sten", "jord och sten på vägen")
        .gsub("Länsgr. H/K", "länsgränsen mellan Kalmar och Blekinge")
        .gsub("Länsgräns H/K", "länsgränsen mellan Kalmar och Blekinge")
        .gsub("väg 6 ", "E6")
        .gsub("/", ", ")
        .gsub("köerMot", "köer mot")
        .gsub(/(\i )([A-ZÅÄÖ][a-zåäö]+) (\län)/, "")
        .gsub(/(\i )([A-ZÅÄÖ][a-zåäö]+) ([A-ZÅÄÖ][a-zåäö]+) (\län)/, "")
    end

    def checksum(json)
      Digest::MD5.hexdigest(json.to_s).to_s
    end

    def slack(m, article)
      omrkod = m[@need[5]]
      message = {
      title: article[:title],
      pretext: "Ny varning från Trafikverket",
      text: "#{article[:ort]}\n#{article[:ingress]}\n#{article[:body]}",
      mrkdwn_in: ["text", "pretext"]
      }
      omrkod.each do |i|
        if i != 2
          Agents::TRAFIKVERKET::Tv::CHANNEL[Agents::TRAFIKVERKET::Tv::LANSNUMMER[i]].each do |c|
            Agents::SLACK::MESSAGE.slacking(c, article, message)
          end
        end
      end
    end

    def slacka(m, article)
      omrkod = m[@need[5]]
      omrkod.each do |i|
        if i != 2
          Agents::TRAFIKVERKET::Tv::CHANNEL[Agents::TRAFIKVERKET::Tv::LANSNUMMER[i]].each do |c|
            message = {
              title: article[:title],
              pretext: "Ny varning från Trafikverket",
              text: "#{article[:ort]}\n#{article[:ingress]}\n#{article[:body]}",
              mrkdwn_in: ["text", "pretext"],
              channel: c
              }
            create_event payload: message
          end
        end
      end
    end

    def check
      @post_body =
        "<REQUEST>
         <LOGIN authenticationkey='#{options["api_key"]}' />
         <QUERY objecttype='Situation'>
          <FILTER>
            <OR>
							<ELEMENTMATCH>
							  <EQ name='Deviation.ManagedCause' value='true' />
							  <IN name='Deviation.MessageType' value='Trafikmeddelande,Olycka' />
							</ELEMENTMATCH>
							<ELEMENTMATCH>
							  <EQ name='Deviation.MessageType' value='Färjor' />
							  <EQ name='Deviation.IconId' value='ferryServiceNotOperating' />
							</ELEMENTMATCH>
							<ELEMENTMATCH>
							  <EQ name='Deviation.MessageType' value='Restriktion' />
							  <EQ name='Deviation.MessageCode' value='Väg avstängd' />
							</ELEMENTMATCH>
							<ELEMENTMATCH>
					      <EQ name='Deviation.MessageType' value='Vägarbete' />
					      <EQ name='Deviation.SeverityCode' value='5' />
							</ELEMENTMATCH>
							<ELEMENTMATCH>
					      <NE name='Deviation.MessageType' value='Vägarbete' />
					      <GTE name='Deviation.SeverityCode' value='4' />
							</ELEMENTMATCH>
							</OR>
						</FILTER>
          </QUERY>
        </REQUEST>"
    	filter_and_text
    end

    def working?
      !recent_error_logs?
    end

    def redis
      @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
    end

	end
end
