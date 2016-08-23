require "httparty"

module Agents::SMHI::API
  def self.warnings(url)
    response = HTTParty.get(url).parsed_response
    if response == {}
      return nil
    elsif response['alert'].class.name == 'Hash'
      [response['alert']]
    else
    response['alert']
    end
  end

  def self.message(url)
    message = HTTParty.get(url).parsed_response
    if message['message']['text'].nil?
      return nil
    else
      mess = message['message']['text']
      "Väderläget i landet just nu är att #{mess[0].downcase + mess.gsub("\n\n", "")[1..-1]}."
    end
  end
end
