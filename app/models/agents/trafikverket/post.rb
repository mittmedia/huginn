module Agents::TRAFIKVERKET::POST
	def self.post_call(url, payload)
		return if url.empty? || payload.empty?
    response = HTTParty.post url, :body => payload, :headers => {'Content-type' => 'text/xml'}
    JSON.parse(response.body)
	end
end