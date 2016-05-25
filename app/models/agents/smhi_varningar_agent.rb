require 'httparty'
require 'json'
require 'date'
require 'slack-notifier'
require 'digest/md5'
require 'redis'

module Agents
  class SmhiVarningarAgent < Agent
    default_schedule "every_5m"
    description <<-MD
      Agent för att omvandla svar från SMHI:s API till nyhetsartiklar.
      Gör en GET-request till API:et och returnerar JSON-objekt.
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

    def redis
      @redis ||= Redis.new(:host => '127.0.0.1', :port => 6379, :db => 15)
    end

    def default_options
     { "warnings_url" => "http://opendata-download-warnings.smhi.se/api/alerts.json",
      "message_url" => "http://opendata-download-warnings.smhi.se/api/messages.json",
      "test" => ""
     }
    end

    def validate_options
     errors.add(:base, "warnings_url is required") unless options['warnings_url'].present?
     errors.add(:base, "message_url is required") unless options['message_url'].present? 
    end

    def varningstext(prio)
      if prio == 2
        "En klass 1-varning innebär en väderutveckling som innebär vissa risker för allmänheten och störningar för en del samhällsfunktioner. Eftersom väderläget kan ändras snabbt så rekommenderar SMHI att håller sig uppdaterad om utvecklingen via media och andra källor."
      elsif prio == 4
        "En klass 2-varning innebär att en väderutveckling väntas som kan innebära fara för allmänheten, stora materiella skador och stora störningar i viktiga samhällsfunktioner.
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

    def check
      # redis.flushall
      handelser = SMHI::API.warnings(options['warnings_url'])
      res = {articles:[]}
      handelser.each do |a|
        article = {}
        tags = {}
        omrkod = a['info']['area']['areaDesc']
        article[:SMHI_agent_version] = "1.0"
        article[:article_created_at] = Time.zone.now
        article[:data_posted_at] = a['sent']
        article[:systemversion] = a['code'][2][-1].to_i
        article[:id] = a['identifier']
        article[:point] = SMHI::Geometri::POINT[omrkod[0..2]]
        article[:lat] = article[:point].split[0][6..-1]
        article[:long] = article[:point].split[1][0..-2]
        article[:poly] = a['info']['area']['polygon'] if a['info']['area'].has_key? 'polygon'
        article[:prio] = SMHI::Rubrik::PRIO[a['info']['eventCode'][0]['value']]  # Nyhetsprio 2,4 eller 6
        article[:rubrik] = SMHI::Rubrik::RUBBE[SMHI::Rubrik::ETIKETT[a['info']['eventCode'][0]['value']]]
        article[:omr] = area_transformation(omrkod)
        article[:ingress] = build_ingress(a, article)
        article[:brodtext] = build_brodtext(a, article)
        article[:exact_poly] = SMHI::Geometri::POLYGON[omrkod]
        tags[:id] = "Number"
        tags[:main] = "Vädervarning"
        tags[:other1] = "SMHI"
        tags[:other2] = a['info']['eventCode'][1]['value']
        article[:tags] = ["tag" => [tags]]
        if article[:systemversion] > 1
          # skicka till slack att en uppdatering gjorts
          next
        end
        digest = checksum(article[:id], article[:ingress])
        next if digest == redis.get(article[:id])
        res[:articles] << article
        redis.set(article[:id], digest)
        slack(omrkod, article)
      end
      if res[:articles].length > 0 then create_event payload: res end
      return res
    end

    def rensa_fel(text)
      text.gsub("\"", "")
        .gsub("m/s", "meter per sekund")
        .gsub(". .", ".")
        .gsub(/(\D)\.(\S)/, '\1. \2')
        .gsub(". .", ". ")
        .gsub("ca", "cirka")
        .gsub("idag", "i dag")
        .gsub("Idag", "I dag")
        .gsub("blir i eftermiddag stor", "blir stor i eftermiddag")
    end

    def build_ingress(a, article)
      varning_for = SMHI::Rubrik::SVOVERS[a['info']['eventCode'][3]['value']]
      ingress = "SMHI har gått ut med #{varning_for}. Meddelandet rör #{article[:omr]}."
      ingress = rensa_fel(ingress)
    end

    def build_brodtext(a, article)
      d = DateTime.parse(a['sent'])
      veckodag = SMHI::Datumsv::DAGAR[d.wday]
      klockslag = d.strftime("%R").gsub(":", ".")
      mess1 = a['info']['description']
      mess2 = a['info']['eventCode'][1]['value']
      brodtext = "Varningen skickades ut klockan #{klockslag} på #{veckodag} och man meddelar att #{mess1.downcase.strip}
#{SMHI::API.message(options['message_url'])} #{varningstext(article[:prio])}"
      brodtext = rensa_fel(brodtext)
    end

    def slack(omrkod, article)
      if omrkod.length > 3
        area = omrkod.split(",")
      else
        area = [omrkod]
      end
      area.each do |i|      
        Agents::SMHI::Distrikt::CHANNEL[Agents::SMHI::Distrikt::OMR[i]].each do |c|
          Agents::SLACK::MESSAGE.slacking(c, article)
        end
      end
    end

    def skriv_json(articles)
      File.open('nytttest.json', 'w') do |file|
        file.puts(articles.to_json)
      end
    end

    def checksum(id, ingress)
      Digest::MD5.hexdigest(id + ingress).to_s
    end

    def working?
     !recent_error_logs?
    end
  end
end
