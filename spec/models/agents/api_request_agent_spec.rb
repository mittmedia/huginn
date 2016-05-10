require 'rails_helper'


describe Agents::ApiRequestAgent do
  before do
    @valid_options = {
      'url' => ["http://www.st.nu", "http://opendata-download-warnings.smhi.se/api/alerts.json"],
      'expected_update_period_in_days' => "2"
    }
    stub_request(:any, /st.nu/).to_return(:body => "Hej kom och hjälp mig hopp", :status => 200)
    stub_request(:any, /smhi.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/smhi_alerts.json")), :status => 200)
  end

  let(:agent) do
    _agent = Agents::ApiRequestAgent.new(:name => "ApiRequestAgent", :options => @valid_options)
    _agent.user = users(:bob)
    _agent.save!
    _agent
  end

  describe "validations" do
    it "should validate the presence of url" do
      agent.options['url'] = ["http://google.com"]
      expect(agent).to be_valid

      agent.options['url'] = ["http://www.st.nu", "http://www.allehanda.se"] 
      expect(agent).to be_valid

      agent.options['url'] = ""
      expect(agent).not_to be_valid

      agent.options['url'] = nil
      expect(agent).not_to be_valid
    end
  end

  describe "emitting events" do
    it "should emit items as events" do
      expect {
        agent.check
    }.to change { agent.events.count }.by(1)

    #   first, *, last = agent.events.last(20)
      expect(agent.events.first.payload.to_s).to include("Faran för gräsbränder är i dag stor")
      expect(agent.events.first.payload["svar"][1]['alert'].length).to eq(9)
    end
  end
end
