require "date"
require "active_support/time"
require "json"
require 'net/http'
require 'slack-notifier'
require "redis"
require 'digest/md5'

module Agents
  class TrafikverketAgent < Agent
    default_schedule "every_5m"
    description <<-MD
    	Agent för omvandling av data från Trafikverkets öppna API till nyhetsartiklar.
    	Tar emot data via en POST-request och returnerar ett JSON-objekt.
    MD

    def redis
      @redis ||= Redis.new(:host => '127.0.0.1', :port => 6379, :db => 15)
    end

    def default_options
      { "url_string" => "http://api.trafikinfo.trafikverket.se/v1.1/data.json",
      	"api_key" => "984fb975e4c540ccae03ec5558b2e657" }
    end

    def validate_options
      errors.add(:base, "url_string is required") unless options['url_string'].present?
    end

    def valid_alert?(m)
      @need = ['MessageCodeValue', 'SeverityCode', 'VersionTime', 'LocationDescriptor', 'Message', 'CountyNo', 'Geometry', 'MessageType']
      @useful = ['RoadNumber', 'EndTime']
      # Filtrerar bort poster som inte är ursprungsposter
    	if m['ManagedCause'] != true && m['CreationTime'] > m['StartTime']
         	# p "m['ManagedCause']"
          return false
        end
        if DateTime.parse(m['CreationTime']).today? == false
        	return false
      	end
        # Filtrerar bort ofullständiga poster 
        if (m.keys & @need).length < 8
        	# p (m.keys & @need)
          return false
        end
        # Filtrerar bort allt utom systemversion 1
        if m['Id'][15] != "1"
        	# Här borde det finnas en slack output
        	# p m['Id']
          return false
        end
        # Filtrerar bort allt med prio mindre än 4
        if m[@need[1]] < 4
        	# p "prio"
          return false
        end
      return true
    end

    def roadwork_repeat(m)
      if m[@need[0]] == "roadworks" && m.has_key?('EndTime')
        if DateTime.parse(m['EndTime']).today? == false && DateTime.parse(m[@need[2]]).today?
            p "vägarbete slutar: #{m['EndTime']}"
            return false
        else
            return true
        end
        # p m['ManagedCause'].to_s
      end
    end

    def filter_and_text
     	data = Agents::TRAFIKVERKET::POST.post_call(options['url_string'], @post_body)
      count = 0
      lan = []
      res = {articles:[]}
      data['RESPONSE']['RESULT'][0]['Situation'].each do |d|
        d['Deviation'].each do |m|
          article = {}
          next unless valid_alert?(m)
          next unless roadwork_repeat(m)
          article[:rubrik] = uppdatera_rubrik(build_headline(m), m)
          article[:ort] = lansomv(m)
          article[:ingress] = rensa_fel(build_ingress(m))
          article[:brodtext] = rensa_fel(build_brodtext(m))
          article[:prio] = m[@need[1]]
          article[:udid] = m['Id']
          article[:uid] = d['Id']
          article[:lat] = m[@need[6]]['WGS84'].split[2][0..-2]
          article[:long] = m[@need[6]]['WGS84'].split[1][1..-1]
          article[]
          digest = checksum(article)
          next if digest == redis.get(article[:udid])
          res[:articles] << article
          redis.set(article[:udid], digest)
          # slacking(article)
          count += 1
        end
      end
      # puts "Antal artiklar skickade: #{count}"
      # redis.flushall
      create_event payload: res
      res
  	end

    def build_headline(m)
      rubrik = Agents::TRAFIKVERKET::Tv::RUBRIKER[Agents::TRAFIKVERKET::Tv::PRIONIV[m[@need[1]]]][Agents::TRAFIKVERKET::Tv::LEVEL[m[@need[0]]]]
      if rubrik.nil?
        # Här borde skickas felmeddelande till Slackkanal mded följande info: p m[@need[0]] + m[@need[4]]
        rubrik = "Trafikverket går ut med varning till allmänheten"
      end
      return rubrik
    end

    def build_ingress(m)
        "#{Agents::TRAFIKVERKET::Tv::BESKR[m[@need[0]]]} orsakar problem för trafikanter vid #{m[@need[3]]}, Trafikverket går ut och varnar trafikanter i området."
    end

    def build_brodtext(m)
      meddelande = m[@need[4]]
      versionstid = DateTime.parse(m[@need[2]])
      dag = Agents::TRAFIKVERKET::Tv::DAGAR[versionstid.wday]
      sluttid = DateTime.parse(m[@useful[1]])
      "Varningen gäller #{Agents::TRAFIKVERKET::Tv::MEDDELANDETYP[m[@need[7]]].downcase} och det som orsakar störningen är #{meddelande[0].downcase + meddelande[1..-1].gsub("\r\n", "")}. Det hela påverkar #{m[@need[3]]}.
Varningen gick ut på #{dag} klockan #{versionstid.strftime("%R")}. #{sluttid_n(versionstid, sluttid)}
Den här artikeln är skriven av Mittmedias textrobot med hjälp av öppen data från Trafikverket."
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

    def uppdatera_rubrik(rubrik, m)
      if not m[@useful[0]].nil?
        if m[@useful[0]][0] == "E"
          "#{rubrik} på #{m[@useful[0]].split[0]}#{m[@useful[0]].split[1]}"
        else
          "#{rubrik} på #{m[@useful[0]].downcase}"
        end
      else
        rubrik
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
        .gsub(" S ", " södra ")
        .gsub(" N ", " norra ")
        .gsub(" Ö ", " östra ")
        .gsub(" V ", " västra ")
        .gsub("automatiskt kömeddelande : I riktning (N)       .", "långa köer i nordlig riktning")
        .gsub("automatiskt kömeddelande : I riktning (S)       .", "långa köer i sydlig riktning")
        .gsub("automatiskt kömeddelande : I riktning (Ö)       .", "långa köer i östlig riktning")
        .gsub("automatiskt kömeddelande : I riktning (V)       .", "långa köer i västlig riktning")
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
    end

    def checksum(json)
      Digest::MD5.hexdigest(json.to_s).to_s
    end

    def check
      @post_body =
        "<REQUEST>
         <LOGIN authenticationkey='#{options["api_key"]}' />
         <QUERY objecttype='Situation' limit='1000'>
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
	end
end