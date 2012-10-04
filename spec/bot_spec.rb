require 'spec_helper'

describe "bot" do
  before(:all) do
    class MyBot < IRC::Bot
      host 'localhost'
      nick 'MyBot'
      channel '#MyChannel', '#OtherChannel'
    end
  end

  it "should have a nick" do
    MyBot.nick.should eq('MyBot')
  end

  it "should have a host" do
    MyBot.host.should eq('localhost')
  end

  it "should have a port" do
    MyBot.port.should eq(6667)
  end
end
