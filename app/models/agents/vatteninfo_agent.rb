module Agents
  class VatteninfoAgent < Agent
    default_schedule "every_1m"
    description <<-MD
      Leverar driftinfo från Miljö och Vatten i Örnsköldsvik AB.
    MD

    def default_options
      {
        'channel' => '#larm_vatten_ovik'
      }
    end
    
    def validate_options
      errors.add(:base, "channel is required") unless options['channel'].present?
    end

    def working?
      !recent_error_logs?
    end

    def check
      data = extract_info
      data.each do |item|
        next unless time_filter(item[1]) == true
        # return nil if WRAPPERS::REDIS.digest(item[0], item) == false
        send_event(find_data(item[3]), item[3])
        
        # find_data(parse_html(item[3]))
      end
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
      data[:info].each do |s|
        d = to_hash(s.strip)
        data[:data][d[0]] = d[1] 
      end
      return data
    end

    def generate_text(data)
      text = {}
      tid = omv_tid(data)
      text[:title] = data[:title]
      text[:body] = clean_text("Enligt MIVA är det en #{data[:title].split[0].downcase.strip} på #{data[:data]["Berört område"].strip} som även kan påverka #{data[:data]["Övriga berörda områden"].strip}\nArbetet påbörjades på #{Agents::TRAFIKVERKET::Tv::DAGAR[tid[0].wday]} och man räknar med att arbetet kommer fortgå åtminstone till #{tid_text(tid)}")
      return text
    end

    def clean_text(text)
      text.gsub("  ", " ")
          .gsub(" .", ".")
    end

    def tid_text(tid)
      if tid[0].wday != tid[1].wday
        "#{Agents::TRAFIKVERKET::Tv::DAGAR[tid[1].wday]} den #{tid[1].day} #{Agents::TRAFIKVERKET::Tv::MANAD[tid[1].month]} klockan #{tid[1].strftime("%R")}."
      else
        "klockan #{tid[1].strftime("%R")}."
      end
    end

    def omv_tid(data)
      time = []
      tm = data[:data]["Påbörjas"].split
      tm2 = data[:data]["Beräknas åtgärdad"].split
      tm[4] = "#{tm[4]}:00"
      tm2[4] = "#{tm2[4]}:00"
      time << Time.parse("#{tm[0]} #{tm[1]} #{tm[2]} #{tm[4]}")
      time << Time.parse("#{tm2[0]} #{tm2[1]} #{tm2[2]} #{tm2[4]}")
      return time
    end

    def time_filter(time)
      t = Time.parse(time)
      span = t - Time.zone.now
      p span
      # if span < 10000 # for test
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

    def send_event(data, url)
      return if data.nil?
      message = {
        article: data,
        title: data[:text],
        channel: "#larm_vatten_ovik",
        pretext: data[:title],
        text: "#{generate_text(data)}\nLäs mer på #{url}",
        mrkdwn_in: ["text", "pretext"]
        }
      create_event payload: message
    end
  end
end