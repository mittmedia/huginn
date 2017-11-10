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
      "Nu har jag lekt lite med nya verktyget Newsworthy (och infogram) och gjort ett flertal läns/landskaps/stads-versioner av en väderartikel. 

Jag hann inte klart med samtliga artiklar idag, så om intresse finns gör jag klart resten av MM på måndag. 

Dessa är iaf klara i nuläget och kan publiceras när ni vill och kan, från och med nu: 
•Grafik: Ovanligt mycket regn i oktober i Västmanland – Hallstaberg mest drabbat 
http://writer.prod.mitm.infomaker.io/#46630cb9-6d70-423f-aa3f-20fefdaeb30b
• Grafik: Ovanligt mycket regn i oktober i Hälsingland – Ljusdalsborna mest drabbade
http://writer.prod.mitm.infomaker.io/#318efed1-d76c-4367-8c37-2efaad916832
• Grafik: Rekordmycket regn i oktober i Norrtälje – mer än på 81 år
http://writer.prod.mitm.infomaker.io/#0ec849d1-daeb-4dd1-adbc-ef3652da921e
• Grafik: Ovanligt mycket regn i oktober i Nynäshamn – En av de mest regndrabbade månaderna sedan 1935
http://writer.prod.mitm.infomaker.io/#bb6af75f-95f1-4700-b731-0aab94164570
• Grafik: Ovanligt mycket regn i oktober i Södertälje – En av de mest regndrabbade månaderna sedan 1931
http://writer.prod.mitm.infomaker.io/#d4545559-64c1-4498-8088-b498ad7b147b
• Grafik: Ovanligt mycket regn i oktober i Jämtland – Västerövsjö värst drabbat
http://writer.prod.mitm.infomaker.io/#a9a93c72-4f40-45db-a5a1-1fa9e7dcf1c6
• Grafik: Ovanligt mycket regn i oktober i Medelpad – Timråborna mest drabbade
http://writer.prod.mitm.infomaker.io/#fa0dc874-c5d2-4345-a23b-69420b88f716
• Grafik: Ovanligt mycket regn i oktober i Ångermanland – Gideåborna mest drabbade
http://writer.prod.mitm.infomaker.io/#09232ef5-bf8f-4731-97ba-be1f6ab67ed8
• Grafik: Ovanligt mycket regn i oktober i Dalarna – Långshyttan mest drabbat 
http://writer.prod.mitm.infomaker.io/#32594015-e541-4f05-89b1-c8dddda83dfc
@here"
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