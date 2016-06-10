require "httparty"

# Används genom att anropa funktionen i en loop genom en lista med slackkanaler

module Agents::SLACK::MESSAGE
	def self.slacking(c, article, message)
    notifier = Slack::Notifier.new "https://hooks.slack.com/services/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",
      channel: c,
      username: 'Mittmediabotten'
      # Meddelande formaterat som följer: 
    # message = {
    #   title: article[:rubrik],
    #   pretext: "Ny vädervarning från SMHI",
    #   text: "#{article[:omr]}\n#{article[:ingress]}\n#{article[:brodtext]}",
    #   mrkdwn_in: ["text", "pretext"]
    #   }
    notifier.ping "", attachments: [message]
  end
end