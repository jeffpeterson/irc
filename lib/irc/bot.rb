module IRC
  class Bot
    attr_reader :message

    def initialize message
      @message = message
    end

    def say something, recipients = nil
      recipients = [(recipients || self.class.channel)].flatten.join(',')
      message.connection.privmsg something, recipients
    end

    def reply something
      say "#{message.nick}, #{something}"
    end

    def method_missing method_name, *args
      message.public_send method_name, *args
    end

    class << self
      attr_accessor :nick, :host, :port, :channel, :channels

      def start!
        @connection ||= Connection.new @host, @port

        on(:ping) { connection.pong params }

        @connection.nick @nick
        @connection.join @channel

        @connection.listen
      end

      def reset!
        Callback.reset!
      end

      def host _host = nil
        puts "   host: '#{_host}'"
        @host = _host || @host
      end

      def port _port = nil
        puts "   port: '#{_port}'"
        @port = _port || @port
      end

      def nick _nick = nil
        puts "   nick: '#{_nick}'"
        @nick = _nick || @nick
      end

      def channel _channel = nil
        puts "channel: '#{_channel}'"
        @channel = _channel || @channel
      end

      def match regex, &block
        on(:privmsg, regex, &block)
      end

      def mention_match regex, &block
        r = /arcbot(.*)/ + regex
        on(:privmsg, r, &block)
      end

      def on action, regex = nil, &block
        Callback.add(action, regex, self, &block)
      end
    end # class << Bot
  end # class Bot
end # module IRC
