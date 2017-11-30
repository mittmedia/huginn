module Agents::TRAFIKVERKET::MAP
	def self.iframe(lat, long)
    @lat = lat
    @long = long
    code = "<iframe src='#{build_embed}' width=100% height='450' frameborder='0' style='border:0' allowfullscreen></iframe>"
    return code
  end

	def self.flatt(hash, kvdelim='', entrydelim='')
	  hash.inject([]) { |a, b| a << b.join(kvdelim) }.join(entrydelim)
	end

	def self.params_embed
    params = {
    "key" => ENV.fetch('GOOGLE_MAP_EMBED_API_KEY'),
    "center" => "#{@lat},#{@long}",
    "q" => "#{@lat},#{@long}",
    "zoom" => "14",
    "maptype" => "satellite",
    }
  end

  def self.build_embed
  	base_url = "https://www.google.com/maps/embed/v1/view?"
    return "#{base_url}#{flatt(params_embed, "=", "&")}"
  end
end
