require "date"
require "active_support/time"
require "json"
require 'net/http'
require 'slack-notifier'
require "redis" 
require 'digest/md5'
require 'csv'
	
module Agents
	class TrainDelayAgent < Agent
    default_schedule "every_5m"
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

	  def redis
	    @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
	  end

	  def post_anrop(query_type)
	    uri = URI.parse options['url_string']
	    request = Net::HTTP::Post.new uri.path
	    request.body = query(query_type)
	    request.content_type = 'text/xml'
	    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
	    response.body
	  end

	  def distance(loc1, loc2)
	    rad_per_deg = Math::PI/180  # PI / 180
	    rkm = 6371                  # Earth radius in kilometers
	    rm = rkm * 1000             # Radius in meters
	    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
	    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg
	    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
	    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }
	    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
	    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
	    rm * c # Delta in meters
	  end

	  def query_type
	    ["TrainMessage", "TrainStation"]
	  end

	  def query(query_type)
	    "<REQUEST>
	      <LOGIN authenticationkey='#{options['api_key']}' />
	      <QUERY objecttype='#{query_type}'>
	        <FILTER>
	        </FILTER>
	      </QUERY>
	    </REQUEST>"
	  end

	  def version_controll(s)
	    if DateTime.parse(s['LastUpdateDateTime']).today? == false
	      # return true
        # p "#{s['LastUpdateDateTime']} är inte i dag"
	      return false
	    elsif Time.zone.now - Time.parse(s['LastUpdateDateTime']) > 70
	    # elsif Time.parse(s['LastUpdateDateTime']).today? == false
	      # return false
        return true # for testing
	    else
	      return true
	    end
	  end

	  def extract_sentences(sentence)
	    if /kontakta|Kontakta/.match(sentence)
	      # print sentence
	      return ""
	    elsif /Orsaken|På grund av|på grund av|orsak|Orsak|orsaken/.match(sentence)
	      # p /På grund av|på grund av|orsak|Orsak|orsaken|Orsaken/.match(sentence)
	      # p sentence
	      sentence.to_s.strip.chomp
	    elsif /anledningen|Anledningen|inställt|inställd|Inställt|Inställd|inställda|Inställda/.match(sentence)
	      # p /anledningen|Anledningen|inställt|inställd|Inställt|Inställd|inställda|Inställda/.match(sentence)
	      # p sentence
	      sentence.to_s.strip.chomp
	    elsif /Försenat|försenat|förseningar|Förseningar/.match(sentence)
	      sentence.to_s.strip.chomp
	    elsif /Trafikverket har skickat/.match(sentence)
	      sentence.to_s.strip.chomp
	    elsif /medför|Medför|medfört|Medfört/.match(sentence)
	      sentence.to_s.strip.chomp
	    elsif /ersätter|ersätts av|utförs/.match(sentence)
	      sentence.to_s.strip.chomp
	    else
	      return ""
	    end
	  end

	  def clean_text(text)
	      text = text.gsub(/\([^()]*\)/, "") # Reg ex för att rensa paranteser och data däri
	      .gsub("\n\n", "\n")
	      .gsub(" kl ", " klockan ")
	      .gsub(" S ", " södra ")
	      .gsub(" N ", " norra ")
	      .gsub(" Ö ", " östra ")
	      .gsub(" V ", " västra ")
	      .gsub(" C ", " central ")
	      .gsub("/1", " januari")
	      .gsub("/2", " februari")
	      .gsub("/3", " mars")
	      .gsub(/(http:\/\/|)(www\.|)([a-zåäö]+\.[a-zåäö]+)/, "") # regex för att ta bort web-adresser
        .gsub("/4", " april")
        .gsub("/5", " maj")
        .gsub("/6", " juni")
        .gsub("/7", " juli")
        .gsub("/8", " augusti")
        .gsub("/9", " september")
        .gsub("/10", " oktober")
        .gsub("/11", " november")
        .gsub("/12", " december")
        .gsub(/(\d\d):(\d\d)/, '\1.\2')
        .gsub(" pga", "på grund av")
        .gsub("jvstn", "järnvägsstation")
        .gsub(/\n\n|\n/, "")
        .gsub("\r\n", " ")
        .gsub("/", ", ")
        .gsub(/(\d\d):(\d\d)/, '\1.\2')
        .gsub(" - ", " och ")
        .gsub("kl.", "klockan ")
        .gsub("  ", " ")
        .gsub(" .", ".")
        .gsub(" , ", ", ")
        .gsub(".'.", "'.")
        .gsub(".,", ",")
        .gsub(" . ", ". ")
        .gsub(" '.", "'.")
        .gsub(/(\.)([A-ZÅÄÖ]|[a-zåäö])/, '\1 \2')
        .gsub(/([A-ZÅÄÖ])-([A-ZÅÄÖ][a-zåäö]+)/, '\1 och \2')
        .gsub(":", ".")
        .gsub("..", ".")
        .gsub(/^([A-ZÅÄÖ][a-zåäö]+)-([A-ZÅÄÖ][a-zåäö]+)\:/, 'Ett meddelande har gått ut om en tågförsening på sträckan mellan \1 och \2')
        .gsub(/^([\A-ZÅÄÖ][\a-zåäö]+)-([\A-ZÅÄÖ][\a-zåäö]+)\S([\A-ZÅÄÖ][\a-zåäö]+)\:/, 'Ett meddelande har gått ut om en tågförsening på sträckan mellan \1, \2 och \3. ')
        .gsub(/^([A-ZÅÄÖ][a-zåäö]+)-([A-ZÅÄÖ][a-zåäö]+)(|\n|\n\n)/, 'Ett meddelande har gått ut om en tågförsening på sträckan mellan \1 och \2')
        .gsub(/^([A-ZÅÄÖ][a-zåäö]+) - ([A-ZÅÄÖ][a-zåäö]+)(|\n|\n\n)/, 'Ett meddelande har gått ut om en tågförsening på sträckan mellan \1 och \2')
        .gsub(/([A-ZÅÄÖ][a-zåäö]+) - ([A-ZÅÄÖ][a-zåäö]+)/, '\1 och \2')
        .gsub(/^([A-ZÅÄÖ][\a-zåäö]+) - ([A-ZÅÄÖ][a-zåäö]+)\:/, 'Ett meddelande har gått ut om en tågförsening på sträckan mellan \1 och \2')
        .gsub(/(\d\.)(\n\n|\n)/, '\1 ')
        .gsub(/([A-ZÅÄÖ][a-zåäö]+) - ([A-ZÅÄÖ][a-zåäö]+)/, '\1 och \2')
        .gsub(/([a-zåäö]\.)([A-Z])/, '\1 \2')
        .gsub(/([A-ZÅÄÖ][a-zåäö]+)( C | C| C)(\/|,| )/, '\1 central\3')
    end

    def csv
      CSV.read(Rails.root.join('app/models/agents/trafikverket/stations_new.csv'))
    end

	  def check
	    result = {articles:[]}
	    data = JSON.parse(post_anrop(query_type[0]))
	    data['RESPONSE']['RESULT'][0]['TrainMessage'].each do |s|
	      stations_affected = {situation:[]}
	      next unless version_controll(s)
	      article = {}
	      tags = []
	      stations_affected[:situation] << array_of_stations(s)
	      stations_affected[:situation].each do |sit|
	        unless sit.nil?
	          article[:version] = "Trafikverket_Train_V1.0"
            article[:raw] = s['ExternalDescription']
	          article[:generated_at] = Time.zone.now
	          article[:sent] = s['LastUpdateDateTime']
	          article[:title] = build_headline(s, sit)
	          article[:ingress] = build_ingress(s, sit)
	          article[:body] = build_body(s)
	          article[:author] = "Mittmedias Textrobot"
	          article[:affected_counties] = lansomv(s)
	          article[:trafikverket_event_id] = s['EventId']
	          tags << {id: "some_number", name: "Tågförsening"} 
	          tags << {id: "some_number", name: "Trafikverket"}
	          article[:tags] = tags
	          article[:stations] = []
	          sit.each do |geo|
	            csv.each do |c|
	              if geo == [c[2].to_f, c[3].to_f]
	                article[:stations] << {station_short: c[0], station_name: c[1],  municipality: c[5], coordinates: {lat: geo[0], long: geo[1]}} unless c[0] == "Hesv"
	              end
	            end
            end
            article[:number_of_stations_affected] = article[:stations].length
            digest = checksum("#{s['ExternalDescription']}")
            next if redis.get(article[:trafikverket_event_id]).present?
            result[:articles] << article unless article[:body].nil?
            redis.set(article[:trafikverket_event_id], digest)
            @article_counter = redis.incr("Trafikverket_train_article_count")
            send_event(find_channel(article), article)
          end        
        end
      end
    ensure
      redis.quit
    end

    def array_of_stations(s)
      affected = []
      if s['AffectedLocation'].nil?
        return nil
      else
        s['AffectedLocation'].each do |f|
          csv.each do |csv|
            if f == csv[0] 
              affected << [csv[2].to_f, csv[3].to_f]
            end
          end
        end
      end
      affected
    end

	  def find_channel(article)
	    list = []
      article[:stations].each do |s|
        list << Agents::TRAFIKVERKET::Municipalities::SLACK2[s[:municipality]] unless list.include?(Agents::TRAFIKVERKET::Municipalities::SLACK2[s[:municipality]])
      end
      list
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

    def lansomv(s)
      list = []
      lan = s['CountyNo']
      for lansnr in lan
        if lansnr == 2
          next
        else
          list.push(Agents::TRAFIKVERKET::Tv::LANSNUMMER[lansnr])
          if list.length > 1
            ort = list[0..-2].join(", ") + " och " + list[-1]
          else
            ort = list[0]
          end
        end
      end
      return ort
    end

    def find_stations(geo)
      # The geo variable needs to be an Array within an Array with coordinates in WGS84. 
      # For example [[54.23422114, 20.2345612],[54.675346587, 17.435736]]
      pl1 = ""
      pl2 = ""
      if geo.length == 0
        return ""
      elsif geo.length == 1
        csv.each do |csv|
          if geo[0] == [csv[2].to_f, csv[3].to_f]
            return "vid #{csv[1]}"
          end
        end
      elsif geo.length == 2
        csv.each do |c|
          if geo[0] == [c[2].to_f, c[3].to_f]
            pl1 = c[1]
            csv.each do |v|
              if geo[1] == [v[2].to_f, v[3].to_f]
                pl2 = v[1]
                return "mellan #{pl1} och #{pl2}"
              end 
            end
          end
        end
      else
        calculate_distance(geo)
      end
    end

    def multiple_join(array_of_sentences)
      array_of_sentences.each do |check|
        if check == ""
          array_of_sentences.delete(check)
        elsif check[-1] == "."
          check = check[0..-2]
        end
      end
      if array_of_sentences.nil?
        return ""
      elsif array_of_sentences.length == 1
        "#{array_of_sentences[0].strip}."
      elsif array_of_sentences.length == 2
        "#{array_of_sentences[0]} och #{array_of_sentences[1][0].downcase}#{array_of_sentences[1][1..-1]}."
      elsif array_of_sentences.length > 2
        array_of_sentences[0..-2].join(". ") + " och #{array_of_sentences[-1][0].downcase}#{array_of_sentences[-1][1..-1]}."
      end
    end

    def calculate_distance(location)
      if location.length > 1
        location2 = location.reverse
        ind = 0
        max = 0
        long1 = ""
        long2 = ""
        location.each do |l|
          location2.each do |l2|
            dist = distance(l, l2)
            if dist > max
               max = dist
               long1 = l
               long2 = l2
            end
            ind += 1
          end
        end
        csv.each do |csv|
          if long1 == [csv[2].to_f, csv[3].to_f]
            long1 = csv[1]
          end
          if long2 == [csv[2].to_f, csv[3].to_f]
            long2 = csv[1]
          end
        end
        return "#{location.length} stationer mellan #{long1} och #{long2}" 
      else
        return ""
      end
    end

    def checksum(json)
      Digest::MD5.hexdigest(json.to_s).to_s
    end


	  def build_headline(s, sit)
	    "#{Agents::TRAFIKVERKET::Helper::HEADLINE[s['ReasonCodeText']]} orsakar tågförseningar #{find_stations(sit)}".gsub(/ (\d|\d\d|\d\d\d) stationer/, "")
	  end

	  def build_ingress(s, sit)
	    "Förseningar väntas i tågtrafiken på grund av #{Agents::TRAFIKVERKET::Helper::CAUSE[s['ReasonCodeText']]}. 
Störningen gäller #{find_stations(sit)}."
	  end

	  def build_body(s)
	    body_text = []
	    sentences = s['ExternalDescription'].split(/\. |\.\n\n|\.\n|\n|\n\n/) if s['ExternalDescription'].present?      
	    if sentences.present?
	      sentences.each do |sentence|
	        if sentence[-1] == "."
	          sentence = sentence[0..-2]
	        end
	        body_text << extract_sentences(clean_text(sentence))
	      end
	      if multiple_join(body_text) == ""
          return nil
        else
	        "#{multiple_join(body_text)} #{start_time(s)}"
	      end
	    end
	  end

    def start_time(s)
      time = Time.zone.parse(s['StartDateTime'])
      if (time.today?) && (time < Time.zone.now)
        "Arbetet med att få igång trafiken igen påbörjades i dag klockan #{time.strftime("%R").gsub(/(\d\d):(\d\d)/, '\1.\2')}."
      elsif (time.today?) && time > Time.zone.now
        "Arbetet med att få igång trafiken igen påbörjas senare i dag vid klockan #{time.strftime("%R").gsub(/(\d\d):(\d\d)/, '\1.\2')}."
      elsif time < Time.zone.now
        "Arbetet med att få igång trafiken igen påbörjades på #{Trafik::DAGAR[time.wday]}."
      elsif time > Time.zone.now
        "Det planerade arbetet kommer att påbörjas på #{Trafik::DAGAR[time.wday][0..-3]} klockan #{time.strftime("%R").gsub(/(\d\d):(\d\d)/, '\1.\2')}."
      end
    end

    def working?
      !recent_error_logs?
    end
	end
end
