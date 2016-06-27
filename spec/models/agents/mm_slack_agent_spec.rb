require 'rails_helper'

describe Agents::MmSlackAgent do
	before(:each) do
    @fallback = "Its going to rain"
    @attachments = [{'fallback' => "fallback"}]
    @valid_params = {
                      'webhook_url' => 'https://hooks.slack.com/services/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',
                      'channel' => '#robottest',
                      'username' => "username",
                      'message' => "hej",
                      'attachments' => @attachments
                    }

    @checker = Agents::MmSlackAgent.new(:name => "slacker", :options => @valid_params)
    @checker.user = users(:jane)
    @checker.save!

    @event = Event.new
    @event.agent = agents(:bob_weather_agent)
    @event.payload = {
  "title": "Just nu: område ännu inte avspärrat efter olycka på väg 50 mellan Fågelsta och Skänninge Norra",
  "pretext": "Ny varning från Trafikverket",
  "text": "Östergötland\nEn olycka där man ännu inte har kunnat spärra av vägen orsakar problem i trafiken på väg 50  från Trafikplats Fågelsta till Trafikplats Skänninge Norra i riktning mot Mjölby i Östergötlands län.\nTrafikverket rapporterar störningar i trafiken på väg 50 och orsaken är singeloycka. Det hela påverkar väg 50 från Trafikplats Fågelsta till Trafikplats Skänninge Norra i riktning mot Mjölby i Östergötlands län.\nVarningen gick ut på måndagen klockan 15.36. Man beräknar att trafiken kommer påverkas fram till klockan 16.00.",
  "mrkdwn_in": [
    "text",
    "pretext"
  ],
  "channel": "#robottest"
}
    @event.save!
    # @event
    # p @event
  end

  describe 'validate_options' do
  	before do
      expect(@checker).to be_valid
    end

    it "should require a webhook_url" do
      @checker.options['webhook_url'] = nil
      expect(@checker).not_to be_valid
    end

    it "should require a channel" do
      @checker.options['channel'] = nil
      expect(@checker).not_to be_valid
    end

    it "should allow attachments" do
      @checker.options['attachments'] = nil
      expect(@checker).to be_valid
      @checker.options['attachments'] = []
      expect(@checker).to be_valid
      @checker.options['attachments'] = @attachments
      expect(@checker).to be_valid
    end
  end

  describe "#receive" do
    it "receive an event without errors" do
      any_instance_of(Slack::Notifier) do |obj|
        mock(obj).ping                      
      end
      expect { @checker.receive([@event]) }.not_to raise_error
    end
    it "should evaluate event and go forward with the one formatted as a Slack message" do
    	any_instance_of(Slack::Notifier) do |obj|
        mock(obj).ping                      
      end
    	m = @checker.receive(@event)
    	# p m[0]['payload']['channel']
    end

  end

  describe "#working?" do
    it "should call received_event_without_error?" do
      mock(@checker).received_event_without_error?
      @checker.working?
    end
  end
end