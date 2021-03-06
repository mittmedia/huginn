module Agents
  class SlackMessAgent < Agent
    cannot_be_scheduled!
    description <<-MD
      Används för att pusha ut intern information till flera kanaler i Slack samtidigt.
    MD

    def default_options
      {
        'channel' => '#robottest',
        'pretext' => 'Ett meddelande från Plusdesken',
        'title' => 'Plusdesken'
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
    
    def receive(incoming_events)
      event = incoming_events.to_json_with_active_support_encoder
      event = JSON.parse(event[1..-2])
      log event['payload']['headers']['Subject']
      print event['payload']
      where_to = event['payload']['headers']['Subject'].to_s
      text = event['payload']['plain']
      channels = Agents::WRAPPERS::Headline::CHANNELS[where_to]
      if channels.nil?
        channels = event['payload']['headers']['Subject'].split(' ')
        channels.each do |c|
          unless (c[0] == "#") || (c[0] == "@")
            log "Felaktig kanal: #{c}"
            channels = channels -= [c]
            next
          end
        end
      end
      log channels
      if channels.nil?
        return
      end
      send_event(channels, text)
    end

    def working?
      !recent_error_logs?
    end

    def send_event(channel_list, text)
      return if text.nil?
      channel_list.each do |c|
        message = {
          article: text,
          title: options['title'],
          channel: c,
          pretext: options['pretext'],
          text: text,
          mrkdwn_in: ["text", "pretext"],
          sent: Time.zone.now
            }
        create_event payload: message
      end
    end
  end
end