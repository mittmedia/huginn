module Agents
  class KrisinfoAgent < Agent        #Byt ut AgentName mot namn på din agent
    default_schedule "every_1m"
    description <<-MD
      Hämtar data från MSB:s API på Krisinformation.se och leverar artiklar till Slack som events 
    MD
    event_description <<-MD
      fylls i när strukturen som passar är känd.
      MD

    def default_options
      # Exempel på hash med options
      # Kallas på så här: options['url_string']
      { "url_string" => "http://api.krisinformation.se/v1/feed?format=json" }
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

    def get_data
      HTTParty.get("http://api.krisinformation.se/v1/feed?format=json").parsed_response
    end

    def check
      data = get_data
      res = {articles:[]}
      data['Entries'].each do |entry|
        next unless time_check(entry)
        article = {}
        channel = []
        article[:id] = entry['ID']
        article[:published_at] = entry['Published']
        article[:updated_at] = entry['Updated']
        article[:title] = entry['Title']
        article[:body] = clean_text(fix_date(entry['Summary']))
        article[:author] = "Mittmedias Textrobot"
        article[:geo] = []
        entry['CapArea'].each do |area|
          article[:geo] << {Area: area['CapAreaDesc'], Coordinate: {Lat: area['Coordinate'].split(",")[1][0..-3].to_f, Long: area['Coordinate'].split(",")[0].to_f}}
          # p article[:geo][:Area]
          article[:geo].each do |a|
            channel << find_channel(a[:Area]) unless channel.include?(find_channel(a[:Area]))
          end
        end
        channel << "#robot_krisinfo"
        @article_counter = redis.incr("Krisinfo_article_count")
        res[:articles] << {article: article, channel:channel}
      end
      send_event(res)
    end

    def time_check(entry) 
      if Time.zone.parse(entry['Updated']).today? == false
        return false
        # true
      else
        return true
      end
    end

    def find_channel(area)
      if Agents::TRAFIKVERKET::Tv::LANSKANAL[area].nil? == false
        Agents::TRAFIKVERKET::Tv::LANSKANAL[area]
      elsif Agents::TRAFIKVERKET::Municipalities::SLACK[area].nil? == false
        Agents::TRAFIKVERKET::Municipalities::SLACK[area]
      else
        return "#larm_ovriga_landet"
      end  
    end

    def send_event(res)
      res[:articles].each do |event|
        event[:channel].each do |send|
          # p event[:article][:body]
          message = {
              article: event[:article],
              title: event[:article][:title],
              pretext: "Ny notis från Mittmedias Textrobot",
              text: "#{event[:article][:body]}\n\n#{event[:article][:author]}",
              mrkdwn_in: ["text", "pretext"],
              channel: send,
              article_count: @article_counter
              }
          create_event payload: message
        end
      end
    end

    def fix_date(text)
      if text.match(/(\d|\d\d)(\/)(\d|\d\d)/).nil?
        text
      else
        var = text.match(/(\d|\d\d)(\/)(\d|\d\d)/) unless text.match(/(\d|\d\d)(\/)(\d|\d\d)/).nil?
        text = text.gsub(/(\d|\d\d)(\/)(\d|\d\d)/, '\1' + " #{Agents::TRAFIKVERKET::Tv::MANAD[var[3].to_i]}")
      end
    end

    def clean_text(text)
      text = text.gsub("E. coli", "E-coli")
                 .gsub(/(\n\n|\n\n\n|\n\n\n\n|\n\n\n\n\n|\n\n\n\n\n\n)/, "")
    end
  end
end