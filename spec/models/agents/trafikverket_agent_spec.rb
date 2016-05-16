require 'rails_helper'
require 'factory_girl_rails'

describe Agents::TrafikverketAgent do
  before(:each) do
    @valid_options = { 
    "url_string" => "http://api.trafikinfo.trafikverket.se/v1.1/data.json",
    "api_key" => "984fb975e4c540ccae03ec5558b2e657" 
    }
    stub_request(:any, /trafikverket.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/trafikverket.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
    
# > build :some_name, foo: "foobar" #will give you
# > { foo: "foobar", baz: "baff" }
  end  
  
  let(:agent) do
    _agent = Agents::TrafikverketAgent.new(:name => "TrafikverketAgent", :options => @valid_options)
    _agent.user = users(:bob)
    _agent.save!
    _agent
  end

  describe "valid_alert?" do
    it "determines if the deviation is the first of its kind, returns false if not" do
      m = build(:trafikverket_warning).stringify_keys
      m.delete('ManagedCause')
      a = agent.valid_alert?(m)
      expect(a).to eq(false)
    end
  
    it "returns false if it's not the first version of the information" do
      # kolla så att det är systemversion 1
      m = build(:trafikverket_warning, :Id => "222222222222222222222222222222222").stringify_keys
      a = agent.valid_alert?(m)
      expect(a).to eq(false)
    end
    it "returns false if the severitycode is too low" do
      # testa så att prion är tillräckligt hög
      m = build(:trafikverket_warning, :SeverityCode => 3).stringify_keys
      a = agent.valid_alert?(m)
      expect(a).to eq(false)
    end
    it "returns true if all other demands are met" do
      # testar så att den returnerar true
      m = build(:trafikverket_warning).stringify_keys
      a = agent.valid_alert?(m)
      expect(a).to eq(true)
    end
  end

  describe "check" do
    it "evaluates if an event is sent" do
      # m = agent.check
      # p m
      expect {
        agent.check
    }.to change { agent.events.count }.by(1) 
    end
    it "evaluates the number of keys in the JSON object" do
      expect(agent.check[:articles][0].length).to eq(8)
    end
    it "makes sure no nil values are sent" do
      m = agent.check
      m[:articles][0].each do |a|
        expect(a[1]).not_to be(nil)
      end
    end
  end
end