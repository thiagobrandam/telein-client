require 'spec_helper'

describe Telein::Client do

  before(:each) do
    Telein.api_key = 'my_api_key'
  end

  after(:each) do
    WebMock.reset!
  end

  it 'returns 999 when no api key is provided' do
    Telein.api_key = nil

    Telein.servers.each do |server|
      stub_request(:get,server.query_url_for('0000000000')).to_return(:body => '99#0000000000')
      stub_request(:get,server.query_url_for('1234345656')).to_return(:body => '98#1234345656')
      stub_request(:get,server.query_url_for('1294345656')).to_return(:body => '41#1294345656')
    end

    client = described_class.new
    client.carrier_code_for('(00) 0000-0000').should == 999
    client.carrier_code_for('(12) 3434-5656').should == 999
    client.carrier_code_for('(12) 9434-5656').should == 999
  end

  it 'returns carrier codes' do
    Telein.servers.each do |server|
      stub_request(:get,server.query_url_for('0000000000')).to_return(:body => '99#0000000000')
      stub_request(:get,server.query_url_for('1234345656')).to_return(:body => '98#1234345656')
      stub_request(:get,server.query_url_for('1294345656')).to_return(:body => '41#1294345656')
    end

    client = described_class.new
    client.carrier_code_for('(00) 0000-0000').should == 100
    client.carrier_code_for('(12) 3434-5656').should == 98
    client.carrier_code_for('(12) 9434-5656').should == 41
  end

  it 'returns server error code when all endpoints are down' do
    Telein.servers.each do |server|
      stub_request(:get,server.query_url_for('0000000000')).to_timeout
      stub_request(:get,server.query_url_for('1234345656')).to_timeout
      stub_request(:get,server.query_url_for('1294345656')).to_timeout
    end

    client = described_class.new
    client.carrier_code_for('(00) 0000-0000').should == 100
    client.carrier_code_for('(12) 3434-5656').should == 101
    client.carrier_code_for('(12) 9434-5656').should == 101
  end

end