module IRC
  class Bot
    attr_reader :message

    def initialize message
      @message = message
    end

    def say something, recipients = nil
      message.connection.privmsg something, recipients || self.class.channels
    end

    def reply something, mention = true
      if message.middle == self.class.nick
        say something, message.nick
      elsif mention
        say "#{message.nick}, #{something}", message.middle
      else
        say something, message.middle
      end
    end

    def store
      IRC::Store.store
    end

    def conjugate noun, lookup = nil
      lookup ||= {
        'me'  => nick, 
        'you' => self.class.nick,
        nick  => 'you'
      }
      noun.gsub /[\w]+/i, lookup
    end

    def method_missing method_name, *args
      message.public_send method_name, *args
    end

    class << self
      attr_accessor :nick, :host, :port, :channels

      def start!
        @connection ||= Connection.new @host, @port

        on(:ping) { connection.pong params }

        @connection.nick @nick
        @connection.join @channels

        @connection.listen
      end

      def reset!
        Callback.reset!
        @channels = []
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
        puts "   nick: '#{_nick}'"  if _nick
        @nick = _nick || @nick
      end

      def store _store, options = nil
        require 'irc/store'

        case _store
        when :redis
          IRC::Store.options = options
        end
      end

      def channel *_channels
        _channels.each do |c|
          puts "channel: '#{c}'"
          (@channels ||= []) << c
        end
      end

      def match regex, &block
        on(:privmsg, regex, &block)
      end

      def mention_match regex, &block
        r = /^#{@nick}(.*)/ + regex
        on(:privmsg, r, &block)
      end

      def on action, regex = nil, &block
        Callback.add(action, regex, self, &block)
      end
    end # class << Bot
  end # class Bot
end # module IRC
