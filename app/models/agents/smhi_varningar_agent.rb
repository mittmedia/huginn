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
        "En klass 1-varning innebär en väderutveckling som innebär vissa risker för allmänheten och störningar för en del samhällsfunktioner."
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

    # Skapa texten till artikeln
    def check
      text
    end

    def area_transformation(a)
     list = []
     omr = a['info']['area']['areaDesc']
      if omr.length > 3
       omr = omr.split(",")
       omr.each do |r|
       list << SMHI::Distrikt::OMR[r]
      end
      "#{list[0..-2].join(", ")} och #{list[-1]}"
     else
      SMHI::Distrikt::OMR[omr].to_s
     end  
    end

    def text
      handelser = SMHI::API.warnings(options['warnings_url'])
      res = {articles:[]}
      handelser.each do |a|
        article = {}
        omrkod = a['info']['area']['areaDesc']
        article[:systemversion] = a['code'][2][-1].to_i
        article[:id] = a['identifier']
        article[:point] = SMHI::Geometri::POINT[omrkod[0..2]]
        article[:lat] = article[:point].split[0][6..-1]
        article[:long] = article[:point].split[1][0..-2]
        article[:poly] = a['info']['area']['polygon'] if a['info']['area'].has_key? 'polygon'
        article[:prio] = SMHI::Rubrik::PRIO[a['info']['eventCode'][0]['value']]  # Nyhetsprio 2,4 eller 6
        article[:rubrik] = SMHI::Rubrik::RUBBE[SMHI::Rubrik::ETIKETT[a['info']['eventCode'][0]['value']]]
        article[:omr] = area_transformation(a)
        article[:ingress] = "Hej #{build_ingress(a, article)}"
        article[:brodtext] = build_brodtext(a, article)
        article[:exact_poly] = SMHI::Geometri::POLYGON[omrkod]
        if article[:systemversion] > 1
          # skicka till slack att en uppdatering gjorts
          # next
        end
        digest = checksum(article[:id], article[:ingress])
        # next if digest == redis.get(article[:id])
        res[:articles] << article
        redis.set(article[:id], digest)
      end
      if res[:articles].length > 0
        create_event payload: res
        res[:articles].each do |art|
          SLACK::MESSAGE.slacking(art)
        end
      end
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
#{SMHI::API.message(options['message_url'])} #{varningstext(article[:prio])}
Det är den aktuella väderprognosen som avgör när och om en varning ska skickas ut. Bedömningen görs av meteorologer och man följer sedan upp varningen kontinuerligt, fram till att väderhändelsen är över.
Väderläget kan också förändras snabbt, vilket gör att varningsklassen kan ändras med kort varsel.
Den här artikeln är hjälp av öppen data från SMHI."
      brodtext = rensa_fel(brodtext)
    end

    def slack_event(article)
      text = {
      title: article[:rubrik],
      pretext: "Ny vädervarning från SMHI",
      text: "#{article[:omr]}\n#{article[:ingress]}\n#{article[:brodtext]}",#{get_diff(article)}",
      mrkdwn_in: ["text", "pretext"]
      }
      create_event payload: text
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
