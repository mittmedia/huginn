require 'json'

module Agents
  class VmaAgent < Agent       
    default_schedule "every_5m"
    description <<-MD
      Hämtar VMA från Sveriges Radios API och skickar ut direkt i Slack.
    MD
    event_description <<-MD
      fylls i när strukturen som passar är känd.
      MD

    def default_options
      # Exempel på hash med options
      # Kallas på så här: options['url_string']
      { "url_string" => "https://vma.sverigesradio.se/api/complete.json" }
    end

    def validate_options
      # Fyll i fler vid behov
      errors.add(:base, "url_string is required") unless options['url_string'].present?
    end

    def redis
      #Läser in Redis miljövariabel
      @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
    end

    def checksum(json)
      Digest::MD5.hexdigest(json.to_s).to_s
    end

    def working?
      !recent_error_logs?
    end

    # def time_check(alert)
    #   if Time.parse(alert['sent']).today? == false
    #     return false
    #   elsif Time.now - Time.parse(alert['sent']) > 70
    #     return false
    #   else
    #     return true
    #   end
    # end

    def check
      res = {article:[]}
      geo = []
      d = https_call
      return if d['count'] == 0
      d['alert'].each do |alert|
        # next unless time_check(alert)
        article = {}
        alert['info'].each do |data|
          article[:id] = alert['identifier']
          article[:sent] = alert['sent']
          article[:title] = data['event']
          article[:body] = data['description']
          article[:certainty] = data['certainty']
          article[:urgency] = data['urgency']
          article[:url] = data['web']
          article[:author] = "Mittmedias Textrobot"
          data['area'].each do |geography|
            article[:geo] = []
            article[:geo] << {'municipality' => geography['geocode'][3]['value']}
            article[:geo] << {'county' => geography['geocode'][1]['value']}
          end
          res[:article] << article
          next if Agents::WRAPPERS::REDIS.set(article[:id], article[:id]) == false
          find_channel(article)
        end
      end
    end

    def https_call
      uri = URI.parse(options['url_string'])  #URI.parse("https://vma.sverigesradio.se/api/complete.json")
      # uri = URI.parse("https://vmatest.sr.se/api/complete.json")    # Test-url
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
      data = http.get(uri.request_uri).body
      JSON.parse(data)
    end

    def find_channel(article)
      list = []
      article[:geo].each do |geo|
        list << Agents::TRAFIKVERKET::Municipalities::SLACK[geo['municipality']] unless list.include?(Agents::TRAFIKVERKET::Municipalities::SLACK[geo['municipality']])
      end
      list.each do |f|
        # for future use of multiple channels
      end
      list << "#robot_vma"
      send_event(list, article)
    end

    def send_event(list, article)
      list.each do |c|
        message = {
            article: article,
            title: article[:title],
            pretext: "Ny notis från Mittmedias Textrobot",
            text: "#{article[:ingress]}\n#{article[:body]}\n\n#{article[:author]}",
            mrkdwn_in: ["text", "pretext"],
            channel: c,
            article_count: @article_counter
            }
        create_event payload: message
      end
    end
  end
end