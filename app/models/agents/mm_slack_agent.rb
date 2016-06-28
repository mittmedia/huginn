module Agents
  class MmSlackAgent < Agent

    cannot_be_scheduled!
    # cannot_create_events!
    no_bulk_receive!

    gem_dependency_check { defined?(Slack) }

    description <<-MD
      The Slack Agent lets you receive events and send notifications to [Slack](https://slack.com/).

      #{'## Include `slack-notifier` in your Gemfile to use this Agent!' if dependencies_missing?}

      To get started, you will first need to configure an incoming webhook.

      - Go to `https://my.slack.com/services/new/incoming-webhook`, choose a default channel and add the integration.
        else      Your webhook URL will look like: `https://hooks.slack.com/services/some/random/characters`

      Once the webhook has been configured, it can be used to post to other channels or direct to team members. To send a private message to team member, use their @username as the channel. Messages can be formatted using [Liquid](https://github.com/cantino/huginn/wiki/Formatting-Events-using-Liquid).

    MD

    def default_options
      {
        'webhook_url' => 'https://hooks.slack.com/services/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',
        'username' => "Mittmedias Textrobot",
        'icon' => ':robot:',
        'channel' => '#robottest',
        'fallback' => "fallback",
        'pretext' => "",
        'attachments' => ""
      }
    end

    def validate_options 
      errors.add(:base, "webhook_url is required") unless options['webhook_url'].present?
      errors.add(:base, "username is required") unless options['username'].present?
      errors.add(:base, "channel i required") unless options['channel'].present?
    end

    def working?
      received_event_without_error?
    end

    def slack_notifier
      @slack_notifier ||= Slack::Notifier.new(options['webhook_url'], username: options['username'], icon: options['icon'])
    end

    def receive(incoming_events)
      puts incoming_events
        # p incoming_events['payload']['channel']
        # Meddelande formaterat som följer: 
        message = {
          title: incoming_events['payload']['title'],
          pretext: incoming_events['payload']['pretext'],
          text: incoming_events['payload']['text'],
          mrkdwn_in: ["text", "pretext"]
          }
        slack_notifier.ping "", channel: "#robottest", attachments: [message]
        create_event payload: message
        # event
      
    end
  end
end
