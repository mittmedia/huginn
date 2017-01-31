module Agents
  class VatteninfoAgent < Agent
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
      return if data == false
      data.each do |item|
        send_event(find_data(parse_html(item[3])), item[3])
        # find_data(parse_html(item[3]))
      end
    end

    def extract_info
      main_info = []
      enum = 0
      @doc = parse_html("#{vars[:base_url]}#{vars[:sub_url]}")
      time = @doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/span[1]/text()").text.gsub("[", "").gsub(".", ":").split("]")
      status = @doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/span[2]/text()").text.split("ärdat")
      head = @doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/a/span/text()")
      @url = @doc.xpath("//*[@class='sv-channel sv-defaultlist ']/li/a/@href")
      time.each do |key|
        return false unless time_filter(time[enum])
        main_info << [head[enum].text, time[enum], status[enum], "#{vars[:base_url] }#{@url[enum]}"]
        enum += 1 
      end
      return main_info
    end

    def find_data(doc) 
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
      return unless WRAPPERS::REDIS.digest(data)
      return data
    end

    def time_filter(time)
      t = Time.parse(time) unless time.nil?
      if t > Time.now-60
        return true
      else
        return false
      end    
    end

    def parse_html(url)
      Nokogiri::HTML(open(url))
    end

    def vars
      {base_url: 'https://miva.se', sub_url: '/kundservice/driftinformation.4.6d76c78f124d9a7776580001345.html'}
    end

    def to_hash(string, arr_sep=',', key_sep=':')
      array = string.split(arr_sep)
      array.each do |e|
        key_value = e.split(key_sep)
        return key_value
      end
    end

    def send_event(data, url)
      message = {
        article: data,
        title: data[:text],
        pretext: data[:title],
        text: "#{data[:info][0]}\n#{data[:info][1]}\n#{data[:info][2]}\n#{data[:info][3]}\nLäs mer på #{url}",
        mrkdwn_in: ["text", "pretext"]
        }
      create_event payload: message
    end
  end
end