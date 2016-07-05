require "httparty"
module Agents
  class GoogleMapAgent < Agent
		cannot_be_scheduled!

  	event_description <<-MD
      Du kan välja karttyp genom att skriva in något av alternativen:
      "roadmap"
      "terrain"
      "satellite"
      "hybrid"

      Här kan du också välja att byta up API-nyckeln.

      MD

    def default_options
      { "maptype" => "hybrid",
      	"api_key" => "AIzaSyCRQ-IqT5cFbaiGjsMc7aesZlXGdRPaGeo" }
    end

    def validate_options
      errors.add(:base, "maptype is required") unless options['maptype'].present?
      errors.add(:base, "api_key is required") unless options['api_key'].present?
    end

		def flatt(hash, kvdelim='', entrydelim='')
	    hash.inject([]) { |a, b| a << b.join(kvdelim) }.join(entrydelim) #unless hash.values.class == Array
		end

		def map(event)
			base_url = "https://maps.googleapis.com/maps/api/staticmap?"
			api_key = options['api_key']
			@lat = event['payload']['lat']
    	@long = event['payload']['long']
			# Google Static Maps API		
			return build_url(base_url, params, markers, api_key)
		end

		def params
			params = {
				"center" => "#{@lat},#{@long}",
				"zoom" => "16",
				"size" => "640x400",
				"maptype" => "hybrid",
				"format" => "png32",
	      "scale" => "2"
			}
		end

		def markers
			markers = [
				"color:red",
	      "size:mid",
	      "#{@lat},#{@long}"
			]
		end

		def build_url(base_url, params, markers, api_key)
			"#{base_url}#{flatt(params, "=", "&")}&markers=#{markers.join("%7C")}&key=#{api_key}"
		end

		def get_data(url)
			HTTParty.get(url).parsed_response
	  end

	  def write_image_file(response)
		  File.open('..//image.jpg', 'w') do |file|
	       # response.body.force_encoding("UTF-8")
	       file.puts(response)
	    end
	  end

	  def receive(incoming_events)
	    event = incoming_events.to_json_with_active_support_encoder
	    event = JSON.parse(event[1..-2])
	    if event['payload']['title'].nil? == false
	      message = {
	        title: event['payload']['title'],
	        channel: "#robottest", #event['payload']['channel'],
	        image: map(event)
	        }
	      create_event payload: message
	    end
	  end

	  def working?
      !recent_error_logs?
    end

    def redis
      @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
    end
	end
end






# "#{base_url}center=#{center}&zoom=#{zoom}&size=#{size}&markers=#{markers[0]}|#{markers[1]}%key=#{api_key}"