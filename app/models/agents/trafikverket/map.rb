module Agents::TRAFIKVERKET::MAP
	def self.iframe(lat, long)
    @lat = lat
    @long = long
    code = "<iframe width=100% height='450' frameborder='0' style='border:0' src='#{build_embed}' allowfullscreen></iframe>"
    return code
  end

	def self.flatt(hash, kvdelim='', entrydelim='')
	  hash.inject([]) { |a, b| a << b.join(kvdelim) }.join(entrydelim)
	end

	def self.params_embed
    params = {
    "key" => ENV.fetch('GOOGLE_MAP_EMBED_API_KEY'),
    "q" => "#{@lat},#{@long}",
    "zoom" => "14",
    "maptype" => "satellite",
    }
  end

  def self.build_embed
  	base_url = "https://www.google.com/maps/embed/v1/place?"
    return "#{base_url}#{flatt(params_embed, "=", "&")}"
  end
end
