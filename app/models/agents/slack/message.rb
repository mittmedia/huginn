require "httparty"

module Agents::SLACK::MESSAGE
	def self.slacking(article)
    Agents::SMHI::Distrikt::CHANNEL[article[:omr]].each do |slack|
      puts "Skickar meddelande till Slack"
      notifier = Slack::Notifier.new "https://hooks.slack.com/services/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",
        channel: slack,
        username: 'Väderbottis'
      message = {
        # fallback: "Nu är det fint ute! Inga vädervarningar i hela landet!",
        title: article[:rubrik],
        pretext: "Ny vädervarning från SMHI",
        text: "#{article[:omr]}\n#{article[:ingress]}\n#{article[:brodtext]}",#{get_diff(article)}",
        mrkdwn_in: ["text", "pretext"]
        }
      notifier.ping "", attachments: [message]
    end 
  end
end