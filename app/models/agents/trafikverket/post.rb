module Agents::TRAFIKVERKET::POST
	def self.post_call(url, payload)
		return if url.empty? || payload.empty?
    uri = URI.parse url
    request = Net::HTTP::Post.new uri.path
    request.body = payload
    request.content_type = 'text/xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
    JSON.parse(response.body)
	end
end