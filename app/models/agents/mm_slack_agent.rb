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

      Once the webhook has been configured, it can be used to post to other channels or direct to team members. To send a private message to team member, use their @username as the channel. 

    MD

    def default_options
      {
        'webhook_url' => '',
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
      event = incoming_events.to_json_with_active_support_encoder
      event = JSON.parse(event[1..-2])
      if event['payload']['title'].nil? == false
        # Meddelande formaterat som följer: 
        message = {
          title: event['payload']['title'],
          pretext: event['payload']['pretext'],
          text: event['payload']['text'],
          mrkdwn_in: ["text", "pretext"]
          }
        slack_notifier.ping "", channel: event['payload']['channel'], attachments: [message]
        # create_event payload: new_event
        # event
      end
    end
  end
end
