module Agents
  class SlackMessAgent < Agent
    cannot_be_scheduled!
    description <<-MD
      Används för att pusha ut intern information till flera kanaler i Slack samtidigt.
    MD

    def default_options
      {
        'channel' => '#robottest'
      }
    end
    
    def validate_options
      errors.add(:base, "channel is required") unless options['channel'].present?
    end

    def working?
      !recent_error_logs?
    end

    def parse_html(url)
      Nokogiri::HTML(open(url))
    end

    def messaget
      "Det här kommer ju gå kanon det =) fixar listorna på måndag! Trevlig helg!=)"
    end
    
    def receive(incoming_events)
      event = incoming_events.to_json_with_active_support_encoder
      event = JSON.parse(event[1..-2])
      log event['payload']
      print event['payload']
      # link = event['payload']['plain'].match(/(http:\/\/miva.se\/\S*.html)/)
      send_event(messaget, options['channel'])
    end

    def working?
      !recent_error_logs?
    end

    def send_event(data,channel)
      return if data.nil?
      message = {
        article: data,
        title: "Plusdesken",
        channel: channel,
        pretext: "Ett meddelande från Plusdesken",
        text: messaget,
        mrkdwn_in: ["text", "pretext"],
        sent: Time.zone.now
        }
      create_event payload: message
    end
  end
end