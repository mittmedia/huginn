require 'httparty'
require 'json'
require 'date'
require 'digest/md5'

module Agents
  class SmhiVarningarAgent < Agent
    default_schedule "every_5m"
    description <<-MD
      Agent för att omvandla svar från SMHI:s API till nyhetsartiklar.
      Gör en GET-request till API:et och returnerar JSON-objekt.
    MD

    event_description <<-MD
      
      MD

    def default_options
     { "warnings_url" => "http://opendata-download-warnings.smhi.se/api/alerts.json",
      "message_url" => "http://opendata-download-warnings.smhi.se/api/messages.json"
     }
    end

    def validate_options
     errors.add(:base, "warnings_url is required") unless options['warnings_url'].present?
     errors.add(:base, "message_url is required") unless options['message_url'].present? 
    end

    def warning_text(prio)
      if prio == 2
        "En klass 1-varning kan innebära vissa risker för allmänheten och störningar för en del samhällsfunktioner. Eftersom väderläget kan ändras snabbt så rekommenderar SMHI att håller sig uppdaterad om utvecklingen via media och andra källor."
      elsif prio == 4
        "En klass 2-varning kan innebära fara för allmänheten, stora materiella skador och stora störningar i viktiga samhällsfunktioner.
  Allmänheten uppmanas att hålla sig uppdaterade med ny information via olika medier."
      elsif prio == 6
        "En klass 3-varning innebär att mycket extremt väder väntas som kan innebära stor fara för allmänheten och mycket stora störningar i viktiga samhällsfunktioner.
  Allmänheten uppmanas att hålla sig uppdaterade med ny information via olika medier."
      else
        ""
      end
    end

    def area_transformation(omrkod)
      list = []
      if omrkod.length > 3
        omr = omrkod.split(",")
        omr.each do |r|
          list << SMHI::Distrikt::OMR[r]
        end
        "#{list[0..-2].join(", ")} och #{list[-1]}"
      else
        SMHI::Distrikt::OMR[omrkod].to_s
      end  
    end

    def system_version_control(article, a)
      if DateTime.parse(a['code'][1][14..-1]).today? == false
        return false
      elsif Time.now - Time.parse(a['code'][1][14..-1]) > 300
        return false
      elsif Time.now - Time.parse(a['sent']) > 300
        return false
      elsif article[:systemversion] == 1
        return true
      else
        diff = Time.zone.now - article[:updated_at]
        if diff < 300
          return true
        else
          return false
        end
      end
    end

    def check
      # redis.flushall
      handelser = SMHI::API.warnings(options['warnings_url'])
      return if handelser.nil?
      mess_response = SMHI::API.message(options['message_url'])
      res = {articles:[]}
      handelser.each do |a| 
        article = {}
        tags = []
        geometry = {}
        article[:systemversion] = a['code'][2][-1].to_i
        article[:updated_at] = Time.parse(a['code'][1][14..-1]) if a['code'][1].present?
        next unless system_version_control(article, a)
        omrkod = a['info']['area']['areaDesc']
        article[:SMHI_agent_version] = "1.0"
        article[:article_created_at] = Time.zone.now
        article[:data_posted_at] = Time.parse(a['sent'])
        article[:id] = a['identifier']
        article[:priority] = SMHI::Rubrik::PRIO[a['info']['eventCode'][0]['value']]  # Nyhetsprio 2,4 eller 6
        article[:title] = SMHI::Rubrik::RUBBE[SMHI::Rubrik::ETIKETT[a['info']['eventCode'][0]['value']]]
        article[:ort] = area_transformation(omrkod)
        article[:ingress] = build_ingress(a, article)
        article[:body] = build_brodtext(a, article, mess_response)
        geometry[:point] = SMHI::Geometri::POINT[omrkod[0..2]]
        geometry[:lat] = geometry[:point].split[0][6..-1]
        geometry[:long] = geometry[:point].split[1][0..-2]
        geometry[:poly] = a['info']['area']['polygon'] if a['info']['area'].has_key? 'polygon'
        geometry[:exact_poly] = SMHI::Geometri::POLYGON[omrkod]
        article[:tags] = ['id': 'some_number', 'name': 'SMHI', 'type': a['info']['eventCode'][0]['value']]
        article[:categories] = ['id': 'some_number', 'name': 'Vädervarning']
        article[:geometry] = geometry
        digest = checksum(article[:id], article[:ingress])
        next if digest == redis.get(article[:id])
        res[:articles] << article
        redis.set(article[:id], digest)
        @article_counter = redis.incr("SMHI_article_count")
        slack(omrkod, article)
      end
      if res[:articles].length > 0 then create_event payload: res end
      return res
      ensure
        redis.quit
    end

    def clean_up_text(text)
      text.gsub("\"", "")
          .gsub("m/s", "meter per sekund")
          .gsub(". .", ".")
          .gsub(/(\D)\.(\S)/, '\1. \2')
          .gsub(". .", ". ")
          .gsub("ca", "cirka")
          .gsub("idag", "i dag")
          .gsub("Idag", "I dag")
          .gsub("blir i eftermiddag stor", "blir stor i eftermiddag")
          .gsub("siljan", "Siljan")
          .gsub(/\. ([a-zåäö])/, '. \1'.uppercase)
    end

    def build_ingress(a, article)
      varning_for = SMHI::Rubrik::SVOVERS[a['info']['eventCode'][3]['value']]
      ingress = "SMHI har gått ut med #{varning_for}. Meddelandet rör #{article[:ort]}."
      ingress = clean_up_text(ingress)
    end

    def build_brodtext(a, article, mess_response)
      d = DateTime.parse(a['sent'])
      veckodag = SMHI::Datumsv::DAGAR[d.wday]
      klockslag = d.strftime("%R").gsub(":", ".")
      mess1 = a['info']['description']
      mess2 = a['info']['eventCode'][1]['value']
      brodtext = "Varningen skickades ut klockan #{klockslag} på #{veckodag} och man meddelar att #{mess1.downcase.strip}
#{mess_response} #{warning_text(article[:prio])}"
      brodtext = clean_up_text(brodtext)
    end

    def slack(omrkod, article)     
      if omrkod.length > 3
        area = omrkod.split(",")
      else
        area = [omrkod]
        area << "00023"
      end
      area.each do |i|
        if Agents::SMHI::Distrikt::CHANNEL[Agents::SMHI::Distrikt::OMR[i]].nil? == true
          message = {
            title: article[:title],
            pretext: "Felmeddelande SMHI:robot",
            text: "#{article} #{i} #{omrkod}",
            mrkdwn_in: ["text", "pretext"],
            channel: "#robottest",
            lat: "article[:geometry][:lat]",
            long: "article[:geometry][:long]"
          }
          create_event payload: message
        else
          Agents::SMHI::Distrikt::CHANNEL[Agents::SMHI::Distrikt::OMR[i]].each do |c|
            message = {
              title: article[:title],
              pretext: "Ny vädervarning från SMHI",
              text: "#{article[:ort]}\n#{article[:ingress]}\n#{article[:body]}",
              mrkdwn_in: ["text", "pretext"],
              channel: c,
              lat: article[:geometry][:lat],
              long: article[:geometry][:long]
              }
            create_event payload: message
            # Agents::SLACK::MESSAGE.slacking(c, article, message)
          end
        end
      end
    end

    def checksum(id, ingress)
      Digest::MD5.hexdigest(id + ingress).to_s
    end

    def working?
     !recent_error_logs?
    end

    def redis
      @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
      # @redis = Redis.new(:host => "127.0.0.1", :port => 6379, :db => 15) # for testing
    end
  end
end
