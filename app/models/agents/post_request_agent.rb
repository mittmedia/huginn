 module Agents
  class PostRequestAgent < Agent
    cannot_receive_events!

    description <<-MD
      Skickar en POST-request till önskat API och returnerar svaret som ett event för andra agenter att använda.
    MD

    event_description "User determined"

    def default_options
      {
        "url_string" => "",
        "request_body_xml" => ""
      }
    end

    def check
        return if options['url_string'].empty? || options['request_body_xml'].empty?
        uri = URI.parse options['url_string']
        request = Net::HTTP::Post.new uri.path
        request.body = options['request_body_xml']
        request.content_type = 'text/xml'
        response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
        create_event payload: JSON.parse(response.body)
    end

    def validate_options
      errors.add(:base, "url is required") unless options['url_string'].present?
      errors.add(:base, "request body is required") unless options['request_body_xml'].present?
    end

    def working?
      true
    end
  end
end
