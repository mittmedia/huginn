require "httparty"

module Agents::SMHI::API
  def self.warnings(url)
    response = HTTParty.get(url).parsed_response
      if response == {}
        puts "Inga varningar aktiva"
      end
      Array(response['alert'])
  end

  def self.message(url)
    message = HTTParty.get(url).parsed_response
    if message == {}
      ""
    else
      mess = message['message']['text']
      "Väderläget i landet just nu är att #{mess[0].downcase + mess.gsub("\n\n", "")[1..-1]}."
    end
  end
end
