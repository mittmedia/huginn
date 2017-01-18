module Agents
  class VatteninfoAgent < Agent
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

    def send_event(list, article)
      list.each do |c|
        message = {
          article: article,
          title: article[:title],
          pretext: "Ny notis från Mittmedias Textrobot",
          text: "#{article[:ingress]}\n#{article[:body]}\n\n#{article[:author]}",
          mrkdwn_in: ["text", "pretext"],
          channel: c,
          article_count: @article_counter
          }
        create_event payload: message
      end
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