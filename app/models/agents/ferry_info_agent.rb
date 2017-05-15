require "json"
require 'net/http'

module Agents
  class FerryInfoAgent < Agent
    default_schedule "every_1m"
    description <<-MD
      Agent för omvandling av data från Trafikverkets öppna API gällande tågföreningar till nyhetsartiklar.
      Tar emot data via en POST-request och returnerar ett JSON-objekt.
    MD
    event_description <<-MD
      fylls i när strukturen som passar är känd.
      MD

    def default_options
      { "url_string" => "http://api.trafikinfo.trafikverket.se/v1.2/data.json",
        "api_key" => "984fb975e4c540ccae03ec5558b2e657" }
    end

    def validate_options
      errors.add(:base, "url_string is required") unless options['url_string'].present?
      errors.add(:base, "api_key is required") unless options['api_key'].present?
    end

    def get_data(id)
      fa_query = Agents::WRAPPERS::POSTREQUESTS.ferry_announcements(options["api_key"], id)
      Agents::TRAFIKVERKET::POST.post_call(options['url_string'], fa_query)
    end

    def get_deviation_data
      situation_query = Agents::WRAPPERS::POSTREQUESTS.ferry_situations(options["api_key"])
      Agents::TRAFIKVERKET::POST.post_call(options["url_string"], situation_query)
    end

    def check  
      all = {deviation:[]}
      dev_data = get_deviation_data
      unless dev_data == {"RESPONSE"=>{"RESULT"=>[{}]}}
        if dev_data['RESPONSE']['RESULT'][0]['Situation'].nil?
          log dev_data
          log "Konstig data från API?"
        end 
        dev_data['RESPONSE']['RESULT'][0]['Situation'].each do |sit|
          devi = {}
          if sit['Deviation'][0]['MessageType'] == "Färjor"
            devi['id'] = sit['Deviation'][0]['Id']
            devi['meddelande'] = sit['Deviation'][0]['Message']
            devi['county'] = sit['Deviation'][0]['CountyNo']  
            devi['publicerat_tid'] = sit['Deviation'][0]['VersionTime']
            info = get_data(devi['id'])
            if info == {"RESPONSE"=>{"RESULT"=>[{}]}}
              log devi
              log "Inget svar från FerryAnnouncement"              
            else
              devi['fran_hamn'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['FromHarbor']['Name']
              devi['till_hamn'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['ToHarbor']['Name']
              devi['beskrivning'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['Route']['Description']
              devi['ruttnamn'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['Route']['Name']
              devi['typ_av_rutt'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['Route']['Type']['Name']
              devi['link'] = sit['Deviation'][0]['WebLink']
              log "Innan redis"
              return if Agents::WRAPPERS::REDIS.set(devi, devi) == false
              all[:deviation] << devi
              log "Gick genom redis"
            end
          end
        end
        send_event(all)
      end
    end

    def send_event(data)
      data[:deviation].each do |dev|
        dev['county'] << 27
        dev['county'].each do |i|
          if i != 2
            if Agents::TRAFIKVERKET::Tv::CHANNEL[Agents::TRAFIKVERKET::Tv::LANSNUMMER[i]].nil?
              log dev['county']
              log i
            end
            Agents::TRAFIKVERKET::Tv::CHANNEL[Agents::TRAFIKVERKET::Tv::LANSNUMMER[i]].each do |c|
              message = {
                ort: dev['county'],
                channel: c,
                article: dev,
                title: "Gäller #{dev['ruttnamn']}",
                pretext: "Färjeinformation från Trafikverkets API",
                text: "Meddelande: #{dev['meddelande']}\n#{dev['typ_av_rutt']} rutt mellan #{dev['fran_hamn']} och #{dev['till_hamn']}.\nBeskrivning av rutt: #{dev['beskrivning']}\nPublicerat: #{dev['publicerat_tid']}\nLänk: #{dev['link']}",
                mrkdwn_in: ["text", "pretext"],
                }
              create_event payload: message
              log "skickade #{message}"
            end
          end
        end
      end
    end

    def working?
      !recent_error_logs?
    end
  end
end