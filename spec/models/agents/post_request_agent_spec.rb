require 'rails_helper'

describe Agents::PostRequestAgent do
  before do
    @valid_options = {
      'url_string' => "http://api.trafikinfo.trafikverket.se/v1.1/data.json",
      'expected_update_period_in_days' => "2",
      "api_key" => "984fb975e4c540ccae03ec5558b2e657"
    }

    stub_request(:any, /trafikverket.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/trafikverket.json")), :status => 200)
  end

  let(:agent) do
    _agent = Agents::PostRequestAgent.new(:name => "PostRequestAgent", :options => @valid_options)
    _agent.user = users(:bob)
    _agent.save!
    _agent
  end

  describe "validations" do
    it "should validate the presence of url_string" do
      agent.options['url_string'] = "http://google.com"
      expect(agent).to be_valid

      agent.options['url_string'] = ""
      expect(agent).not_to be_valid

      agent.options['url_string'] = nil
      expect(agent).not_to be_valid
    end
  end

  describe "validate post request beeing sent" do
      it "should " do

      end

  end

end
