require 'spec_helper'

describe IRC do
  describe IRC::Message do
    before(:each) do
      @message = IRC::Message.new ":nick!username@server PRIVMSG #channel,&channel :trailing\r\n"
    end

    it 'should match valid messages' do
      @message.nick.should     eq('nick')
      @message.user.should     eq('username')
      @message.host.should     eq('server')
      @message.command.should  eq('PRIVMSG')
      @message.params.should   eq(' #channel,&channel :trailing')
      @message.middle.should   eq('#channel,&channel')
      @message.trailing.should eq('trailing')
    end

    it 'should not match invalid messages' do
      invalid_message = IRC::Message.new ":0nick PRIVMSG &channel :trailing\r\n"
      invalid_message.nick.should_not eq('nick')
    end

    it 'should assign action' do
      @message.action.should eq(:privmsg)
    end

    it 'should assign content' do
      message_with_middle = IRC::Message.new "PING middle\r\n"

      @message.content.should eq('trailing')
      message_with_middle.middle.should eq('middle')
    end
  end
end
