require 'rails_helper'


describe Agents::SMHI::API do
  before do
    stub_request(:any, /st.nu/).to_return(:body => "Hej kom och hjälp mig hopp", :status => 200)
    stub_request(:any, /smhi.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/smhi_alerts.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
  end

  describe "warnings" do
    it "it wraps the response in an array if there's single alert" do
      stub_request(:any, /smhi.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/smhi_alerts_single.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
      response = Agents::SMHI::API.warnings("http://opendata-download-warnings.smhi.se/api/alerts.json")
      expect(response).to be_an(Array)
    end
  end
end
