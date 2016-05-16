require 'rails_helper'


describe Agents::SmhiVarningarAgent do
    before(:each) do
        @valid_options = {
            "warnings_url" => "http://opendata-download-warnings.smhi.se/api/alerts.json",
            "message_url" => "http://opendata-download-warnings.smhi.se/api/messages.json",
            'expected_update_period_in_days' => "2"
          }
  end  
  
  let(:agent) do
    _agent = Agents::SmhiVarningarAgent.new(:name => "SmhiVarningarAgent", :options => @valid_options)
    _agent.user = users(:bob)
    _agent.save!
    _agent
  end

  describe "check" do
    it "it puts out an newsarticle as a JSON-object for each SMHI weather warning" do
      stub_request(:any, /smhi.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/smhi_alerts.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
      response = Agents::SMHI::API.warnings("http://opendata-download-warnings.smhi.se/api/alerts.json")
      expect(response.length).to eq(35)
    end
    it "should transform the response into an array if there's only one active warning, and then produce a newsarticle" do
      stub_request(:any, /smhi.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/smhi_alerts_single.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
        response = Agents::SMHI::API.warnings("http://opendata-download-warnings.smhi.se/api/alerts.json")
        expect(response).to be_an(Array)
    end
  end

  describe "build_ingress" do
    it "should build ingress to the newsarticle" do
      stub_request(:any, /alerts.json/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/smhi_alerts.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
      stub_request(:any, /messages.json/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/message.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
      response = agent.check
      # p response
      expect(response[:articles][34][:ingress]).to eq("SMHI har gått ut med en klass 1-varning för kulingvindar. Meddelandet rör Skagerack.")
      response[:articles].each do |a|
        if a[:systemversion] > 1
          p a[:rubrik] + a[:ingress] + a[:brodtext]
        end
      end
    end
  end  
end
