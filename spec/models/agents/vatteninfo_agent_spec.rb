require 'rails_helper'
require 'timecop'

describe Agents::VatteninfoAgent do
  before do
    Timecop.freeze("2017-02-02T06:54:33")
  end

  after do
    Timecop.return
  end
  
  # before do
  #   ENV['REDIS_URL'] = 'foo'
  # end
  
  before(:each) do
    @valid_options = { 
      'channel' => '#larm_vatten_ovik',
    }
    # stub_request(:any, /trafikverket.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/reponse.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
  end

  let(:agent) do
    _agent = Agents::VatteninfoAgent.new(:name => "VatteninfoAgent", :options => @valid_options)
    _agent.user = users(:bob)
    _agent.save!
    _agent
  end

  describe "check" do
    it "finds data in extracted url:s, and also filters by time and previously sent events" do
      stub_request(:any, /miva.se\/kundservice\/driftinformation.4.6d76c78f124d9a7776580001345.html/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/driftinfo_miva.html")), :status => 200, headers: { 'Content-Type' => 'text/html' })
      stub_request(:any, /miva.se\/kundservice\/driftinformation\/driftstorning\/driftstorningdombacksakernihusum.5.13e728d9159df5a4015b6dd.html/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/driftinfo2_miva.html")), :status => 200, headers: { 'Content-Type' => 'text/html' })
      a = agent.check
      p a
    end
  end
end

