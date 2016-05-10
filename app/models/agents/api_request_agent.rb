module Agents
  class ApiRequestAgent < Agent
    default_schedule "every_1d"
    cannot_receive_events!

    description do
        <<-MD
      Skickar en GET-request till önskat API och returnerar svaret som ett event för andra agenter att använda.
        MD
    end

    event_description "User determined"

    def default_options
      { "url" => ""
     }
    end

    def check
        responses = []
        options['url'].each do |url|
          responses << HTTParty.get(url).parsed_response
        end
        create_event payload: {svar: responses}
    end

    def validate_options
      errors.add(:base, "url is required") unless options['url'].present?
    end

    def working?
      true
    end
  end
end
