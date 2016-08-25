
require 'rails_helper'
require 'factory_girl_rails'
require 'timecop'

describe Agents::TrainDelayAgent do
  before do
    ENV['REDIS_URL'] = 'foo'
  end

  before do
    Timecop.freeze("2016-07-07T09:53:33")
  end

  after do
    Timecop.return
  end

  before(:each) do
    @valid_options = { 
    "url_string" => "http://api.trafikinfo.trafikverket.se/v1.1/data.json",
    "api_key" => "984fb975e4c540ccae03ec5558b2e657" 
    }
    stub_request(:any, /trafikverket.se/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/reponse.json")), :status => 200, headers: { 'Content-Type' => 'application/json' })
  end

  let(:agent) do
    _agent = Agents::TrainDelayAgent.new(:name => "TrainDelayAgent", :options => @valid_options)
    _agent.user = users(:bob)
    _agent.save!
    _agent
  end

  describe "version_controll" do
    it "makes sure the data is updated within the last minute" do
      m = build(:train_delay).stringify_keys
      p "Tid nu: #{Time.zone.now}"
      p "uppdaterad: #{m['LastUpdateDateTime']}"
      p Time.zone.now - Time.parse(m['LastUpdateDateTime'])
      a = agent.version_controll(m)
      expect(a).to eq(true)
    end
  end

  describe "clean_text" do
    it "cleans typos from text" do
      m = build(:train_delay).stringify_keys
      a = agent.clean_text(m['sentence'])
      expect(a).to eq("Förseningar kan förekomma mellan Älvsjö och Stockholm Södra på grund av arbeten med Citybanan måndag till natt mot fredag mellan klockan 00.00 och 05.00. Det påverkar SL pendeltåg på sträckorna Södertälje och Märsta, Arlanda central, Uppsala samt Nynäshamn och Bålsta samt fjärrtåg mellan Stockholm central och Uppsala, i båda riktningar.")
    end 
  end

  describe "calculate_distance" do
    it "calculates distance between multiple points and returns the two furthest apart" do
      m = build(:train_delay).stringify_keys
      a = agent.calculate_distance(m['location'])
      expect(a).to eq("8 stationer mellan Bränntjärn och Österport")
    end
  end
end
