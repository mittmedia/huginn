module Agents::TRAFIKVERKET::MAP
	def self.iframe(lat, long)
    @lat = lat
    @long = long
    code = "<iframe width='650' height='450' frameborder='0' style='border:0' src='#{build_embed}' </iframe>"
    return code
  end

	def self.flatt(hash, kvdelim='', entrydelim='')
	  hash.inject([]) { |a, b| a << b.join(kvdelim) }.join(entrydelim)
	end

	def self.params_embed
    params = {
    "q" => "#{@lat},#{@long}",
    "z" => "14",
    "maptype" => "satellite",
    "output" => "embed"
    }
  end

  def self.build_embed
  	base_url = "http://maps.google.com/maps?"
    "#{base_url}#{flatt(params_embed, "=", "&")}"
  end
end
