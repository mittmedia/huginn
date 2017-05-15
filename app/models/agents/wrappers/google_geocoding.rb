module Agents::WRAPPERS::GoogleGeocoding
  def self.geocode(format, address, api_key, bounds)
    url = "https://maps.googleapis.com/maps/api/geocode/#{format}?address=#{address}&bounds=#{bounds}&key=#{api_key}"
    uri = URI(URI.escape(url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
    data = http.get(uri.request_uri).body
    JSON.parse(data)
  end
end

# In order to build url for Google Geocoding API, you need to provide the following:
# Format: either "xml" or "json"
# Address: the search query itself, formatted according to this description: https://developers.google.com/maps/documentation/geocoding/intro#GeocodingRequests
# API-key from Google's Api Console
