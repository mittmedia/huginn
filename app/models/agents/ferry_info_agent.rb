require "json"
require 'net/http'
require 'active_support/Time'

module Agents
  class TrainDelayAgent < Agent
    default_schedule "every_1m"
    description <<-MD
      Agent för omvandling av data från Trafikverkets öppna API gällande tågföreningar till nyhetsartiklar.
      Tar emot data via en POST-request och returnerar ett JSON-objekt.
    MD
    event_description <<-MD
      fylls i när strukturen som passar är känd.
      MD

    def default_options
      { "url_string" => "http://api.trafikinfo.trafikverket.se/v1.1/data.json",
        "api_key" => "984fb975e4c540ccae03ec5558b2e657" }
    end

    def validate_options
      errors.add(:base, "url_string is required") unless options['url_string'].present?
      errors.add(:base, "api_key is required") unless options['api_key'].present?
    end

    def get_data(id)
      api_url_beta = "http://api.trafikinfo.trafikverket.se/beta/data.json"
      fa_query = AGENTS::WRAPPERS::PostRequests.ferry_announcements(options["api_key"], id)
      post_call(fa_query, api_url_beta)
    end

    def get_deviation_data
      api_url = "http://api.trafikinfo.trafikverket.se/v1.1/data.json"
      situation_query = AGENTS::WRAPPERS::PostRequests.ferry_situations(options["api_key"])
      post_call(ferry_query, api_url)
    end

    def post_call(post_body, url)
      uri = URI.parse url
      request = Net::HTTP::Post.new uri.path
      request.body = post_body
      request.content_type = 'text/xml'
      response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
      JSON.parse(response.body)
    end

    def check  
      all = {deviation:[]}
      devi = {}
      dev_data = get_deviation_data
      unless dev_data == {"RESPONSE"=>{"RESULT"=>[{}]}}
        dev_data['RESPONSE']['RESULT'][0]['Situation'].each do |sit|
          if sit['Deviation'][0]['MessageType'] == "Färjor"
            id = sit['Deviation'][0]['Id']
            info = get_data(id)
            devi['meddelande'] = sit['Deviation'][0]['Message']
            devi['county'] = sit['Deviation'][0]['CountyNo']  
            devi['publicerat_tid'] = sit['Deviation'][0]['VersionTime']
            devi['fran_hamn'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['FromHarbor']['Name']
            devi['till_hamn'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['ToHarbor']['Name']
            devi['beskrivning'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['Route']['Description']
            devi['ruttnamn'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['Route']['Name']
            devi['typ_av_rutt'] = info['RESPONSE']['RESULT'][0]['FerryAnnouncement'][0]['Route']['Type']['Name']
            all[:deviation] << devi
          end
        end
      end
      send_event(all)
    end

    def send_event(data)
      data[:deviation].each do |dev|
        dev['county'] << 27
        dev['county'].each do |i|
          if i != 2
            Agents::TRAFIKVERKET::Tv::CHANNEL[Agents::TRAFIKVERKET::Tv::LANSNUMMER[i]].each do |c|
              message = {
                ort: dev['county'],
                channel: c,
                article: dev,
                title: "Gäller #{dev[ruttnamn]}",
                pretext: "Färjeinformation från Trafikverkets BETA-API",
                text: "Meddelande: #{dev['meddelande']}\n#{dev['typ_av_rutt']} rutt mellan #{dev['fran_hamn']} och #{dev['till_hamn']}.\nBeskrivning av rutt: #{dev['beskrivning']}Publicerat: #{dev['publicerat_tid']}\n",
                mrkdwn_in: ["text", "pretext"],
                }
              create_event payload: message
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