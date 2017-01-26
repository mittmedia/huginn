
module Agents
  class VatteninfoAgent < Agent
    description <<-MD
      Leverar driftinfo från Miljö och Vatten i Örnsköldsvik AB.


    MD

    def default_options
      {
        'channel' => '#larm_vatten_ovik',
      }
    end
    
    def validate_options
      errors.add(:base, "channel i required") unless options['channel'].present?
    end

    def working?
      received_event_without_error?
    end

    def find_data(doc) 
      data = {}
      title = '#svid10_55489f891518fcc53d97fcfe'
      data[:title] = doc.css(title).text.gsub(/\r\n/, "\n")
      data[:info] = []
      data[:data] = {}
      xpath = '//*[@id="svid12_55489f891518fcc53d97fd00"]/ul/li'
      list = doc.xpath(xpath)
      list.each do |i|
        data[:info] << i.text
      end
      data[:info].each do |s|
        d = to_hash(s.strip)
        data[:data][d[0]] = d[1] 
      end
      return data
    end

    def send_event(data)
      message = {
        article: data,
        title: data[:title],
        pretext: "Ny notis från Mittmedias Textrobot",
        text: "#{data[:ingress]}\n#{data[:body]}\n\n#{data[:author]}",
        mrkdwn_in: ["text", "pretext"],
        channel: options['channel'],
        article_count: @article_counter
        }
      create_event payload: message
    end

    def receive(incoming_events)
      event = incoming_events.to_json_with_active_support_encoder
      event = JSON.parse(event[1..-2])
      print event
      # if event['payload']['title'].nil? == false
      #   # Meddelande formaterat som följer: 
      #   message = {
      #     title: event['payload']['title'],
      #     pretext: event['payload']['pretext'],
      #     text: event['payload']['text'],
      #     mrkdwn_in: ["text", "pretext"]
      #     }
      #   slack_notifier.ping "", channel: event['payload']['channel'], attachments: [message]
        # create_event payload: new_event
        # event
      # end
    end
  end
end