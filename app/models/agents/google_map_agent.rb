require "httparty"

module Agents
  class GoogleMapAgent < Agent
		cannot_be_scheduled!

  	event_description <<-MD
  			Set zoom level from 1-18.
      MD

    def default_options
      { "zoom_level" => "14" }
    end

    def validate_options
      errors.add(:base, "zoom_level is required") unless options['zoom_level'].present?
    end

		def map_embed
	    base_url = "http://maps.google.com/maps?"
	    build_embed(base_url, params_embed)
	  end

	  def build_embed(base_url, params_embed)
	    "#{base_url}#{flatt(params_embed, "=", "&")}"
	  end

	  def receive(incoming_events)
	    event = incoming_events.to_json_with_active_support_encoder
	    event = JSON.parse(event[1..-2])
	    if event['payload']['title'].nil? == false
	      message = {
	        title: event['payload']['title'],
	        channel: event['payload']['channel'],
	        text: iframe(event)
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