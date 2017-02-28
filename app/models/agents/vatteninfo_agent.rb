module Agents
  class VatteninfoAgent < Agent
    cannot_be_scheduled!
    description <<-MD
      Leverar driftinfo från Miljö och Vatten i Örnsköldsvik AB.
    MD

    def default_options
      {
        'channel' => '#larm_vatten_ovik',
        'api_key' => 'AIzaSyDw1Lo2Qlzw_dqLZYyX7hHgXY7BJSmWt4U',
        'format' => 'json',
        'bounds' => '63.003902,17.866272|63.614616,19.674941'
      }
    end
    
    def validate_options
      errors.add(:base, "channel is required") unless options['channel'].present?
    end

    def working?
      !recent_error_logs?
    end

    def extract_info
      main_info = []
      enum = 0
      doc = parse_html("#{vars[:base_url]}#{vars[:sub_url]}")
      time = doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/span[1]/text()").text.gsub("[", "").gsub(".", ":").split("]")
      status = doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/span[2]/text()").text.split("ärdat")
      head = doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/a/span/text()")
      @url = doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/a/@href")
      time.each do |key|
        main_info << [head[enum].text, time[enum], status[enum], "#{vars[:base_url]}#{@url[enum].text}"]
        enum += 1 
      end
      return main_info
    end

    def find_data(url)
      doc = parse_html(url)
      data = {}
      data[:title] = doc.css('div.sv-text-portlet-content').css('h1').text
      data[:text] = doc.css('div.sv-text-portlet-content')[3].css('p')[0].text
      data[:info] = []
      data[:data] = {}
      xpath = '//*[@id="svid12_55489f891518fcc53d97fd00"]/ul/li'
      list = doc.xpath(xpath)
      list.each do |i|
        data[:info] << i.text.gsub("kl.", "klockan").gsub("Kl.", "klockan")
      end
      return nil if WRAPPERS::REDIS.digest(data[:title], data) == false
      data[:info].each do |s|
        d = to_hash(s.strip)
        data[:data][d[0]] = d[1] 
      end
      return data
    end

    def headline(data)
      if data[:title].split[1] == "i"
        return clean_text("#{Agents::WRAPPERS::Headline::HEADER[data[:title].split[0]]}#{data[:title].split[1..-1].join(" ")}")
      elsif data[:title].split[1] == "med"
        return clean_text("#{Agents::WRAPPERS::Headline::HEADER[data[:title].split[0]]}#{data[:title].split[1..-1].join(" ")}")
      else
        return clean_text("#{Agents::WRAPPERS::Headline::HEADER[data[:title].split[0]]}vid #{data[:title].split[1..-1].join(" ")}")
      end
    end

    def generate_text(data) 
      tid = omv_tid(data)
      clean_text("#{Agents::WRAPPERS::Headline::ENETT[data[:title].split[0]]} #{data[:data]["Berört område"]}#{other_areas(data)}\n#{context(data, tid)}\n#{start_end(tid)}")
    end

    def start_end(time)
      "Arbetet påbörjades på #{Agents::TRAFIKVERKET::Tv::DAGAR[time[0].wday]} vid klockan #{time[0].strftime("%R")}#{end_time(time)}"
    end

    def end_time(time)
      if time.length == 1
        return "."
      elsif time.length > 1
        tid_text(time)
      end
    end

    def context(data, tid)
      unless tid.length == 3
        return Agents::WRAPPERS::Headline::CONTEXT[data[:title].split[0]]
      else
        return ""
      end
    end

    def other_areas(data)
      if data[:data]["Övriga berörda områden"].nil?
        return "."
      else
        data[:data]["Övriga berörda områden"] = data[:data]["Övriga berörda områden"].downcase if data[:data]["Övriga berörda områden"].split[0] == "Eventuellt"
        " som även kan påverka#{data[:data]["Övriga berörda områden"]}."
      end
    end

    def clean_text(text)
      text.gsub("  ", " ")
          .gsub(" .", ".")
          .gsub("..", ".")
          .gsub(" , ", ", ")
          .gsub(/(\d\d):(\d\d)/, '\1.\2')
          .gsub(/M. fl.|m. fl.|mfl|m.fl|M.fl/, "med flera")
          .gsub(/([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)(\.)([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)(\.)([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)/, '\1, \3, \5')
          .gsub(/([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)(\.)([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)/, '\1, \3')
          .gsub(/([a-zåäö])(\.)([a-zåäö]||[A-ZÅÄÖ])/, '\1. \3')
    end

    def clean_headline(text)
      text.gsub(/M. fl.|m. fl.|mfl|m.fl|M.fl/, "")
          .gsub(/([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)(\.)([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)(\.)([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)/, '\1 och \3')
          .gsub(/([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)(\.)([A-ZÅÄÖ][a-zåäö]+|[a-zåäö]+)/, '\1 och \3')
      
    end

    def tid_text(tid)
      if (tid.length == 2) && (tid[0].wday != tid[1].wday)
        " och man räknar med att arbetet kommer fortgå åtminstone till #{Agents::TRAFIKVERKET::Tv::DAGAR[tid[1].wday]} den #{tid[1].day} #{Agents::TRAFIKVERKET::Tv::MANAD[tid[1].month]} klockan #{tid[1].strftime("%R")}."
      elsif (tid.length == 2) && (tid[0].wday == tid[1].wday)
        " och man räknar med att arbetet kommer fortgå åtminstone till klockan #{tid[1].strftime("%R")}."
      elsif tid.length == 3
        " och man kunde avsluta arbetet vid klockan #{tid[2].strftime("%R")}."
      end
    end

    def omv_tid(data)
      time = []
      if data[:data]["Påbörjas"]
        tm = data[:data]["Påbörjas"].split
        if tm.length > 4
          tid = "#{tm[4]}:00"
        else
          tid = "#{tm[3]}:00"
        end
        tm[1] = Agents::TRAFIKVERKET::Tv::MONTH[tm[1]]
        time << Time.parse("#{tm[0]} #{tm[1]} #{tm[2]} #{tid}")
      end
      if data[:data]["Beräknas åtgärdat"]
        data[:data]["Beräknas åtgärdad"] = data[:data]["Beräknas åtgärdat"]
      end
      if data[:data]["Beräknas åtgärdad"]
        tm2 = data[:data]["Beräknas åtgärdad"].split
        if tm2.length > 4
          tid = "#{tm2[4]}:00"
        else
          tid = "#{tm2[3]}:00"
        end
        tm2[1] = Agents::TRAFIKVERKET::Tv::MONTH[tm2[1]]
        time << Time.parse("#{tm2[0]} #{tm2[1]} #{tm2[2]} #{tid}")
      end
      if data[:data]["Åtgärdat"]
        tm3 = data[:data]["Åtgärdat"].split
        tm3[4] = "#{tm3[4]}:00"
        tm3[1] = Agents::TRAFIKVERKET::Tv::MONTH[tm3[1]]
        time << Time.parse("#{tm3[0]} #{tm3[1]} #{tm3[2]} #{tm3[4]}")
      end
      return time
    end

    def time_filter(time)
      t = Time.parse(time)
      span = t - Time.zone.now
      # if span < 30000 # for test
      if (span <= 0.0) && (span >= -61.0)
        return true
      else
        return nil
      end    
    end

    def parse_html(url)
      Nokogiri::HTML(open(url))
    end

    def vars
      {base_url: 'http://miva.se', sub_url: '/kundservice/driftinformation.4.6d76c78f124d9a7776580001345.html'}
    end

    def to_hash(string, arr_sep=',', key_sep=':')
      array = string.split(arr_sep)
      array.each do |e|
        key_value = e.split(key_sep)
        return key_value
      end
    end

    def receive(incoming_events)
      event = incoming_events.to_json_with_active_support_encoder
      event = JSON.parse(event[1..-2])
      link = event['payload']['plain'].match(/(http:\/\/miva.se\/\S*.html)/)
      send_event(find_data(link[0]), link[0])
    end

    def geolocation(adress, data)
      obj = Agents::WRAPPERS::GoogleGeocoding.geocode(options['format'], "#{geo_search_substring(data[:title])},Västernorrland", options['api_key'], options['bounds'])
      if obj['results'] == []
        obj = Agents::WRAPPERS::GoogleGeocoding.geocode(options['format'], adress, options['api_key'], options['bounds'])
      end
      lat = obj['results'][0]['geometry']['location']['lat']
      long = obj['results'][0]['geometry']['location']['lng']
      Agents::TRAFIKVERKET::MAP.iframe(lat, long)
    end

    def geo_search_substring(string)
      sub2 = string.scan(/[A-ZÅÄÖ][a-zåäö]*/)
      if sub2.length == 1
        return "#{sub2.to_s}, Örnsköldsvik"
      else
        sub2.shift 
        return sub2.join(",") 
      end
    end

    def working?
      !recent_error_logs?
    end

    def send_event(data, url)
      return if data.nil?
      message = {
        article: data,
        title: clean_headline(headline(data)),
        channel: options['channel'],
        pretext: "Driftinfo från MIVA",
        text: "#{generate_text(data)}\nLäs mer på #{url}\n\nKarta för inbäddning: #{geolocation("#{data[:title].split[-1]},Västernorrland", data)} @here",
        mrkdwn_in: ["text", "pretext"],
        url: url,
        sent: Time.zone.now
        }
      create_event payload: message
    end
  end
end