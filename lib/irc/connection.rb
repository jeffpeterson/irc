require 'socket'

module IRC
  class Connection
    def initialize host = nil, port = 6667
      @host = host
      @port = port
    end

    def disconnected?
      !@socket || @socket.closed?
    end

    def connected?
      !disconnected?
    end

    def write *strings
      strings.each do |string|
        puts '<- ' + string
        socket.print string + "\r\n"
      end
    end

    def join *channels
      channels.flatten.each do |channel|
        @channel = channel
        write "JOIN #{channel}"
      end
    end

    def part *channels
      channels.flatten.each do |channel|
        write "PART #{channel}"
      end
    end

    def nick _nick, realname = nil
      realname ||= _nick
      write "NICK #{_nick}"
      write "USER #{_nick} localhost #{@host} :#{realname}"
    end

    def privmsg content, *recipients
      recipients = @channel unless recipients.any?
      recipients = [recipients].flatten.join(',')

      msg = "PRIVMSG #{recipients} :#{content}"
      write msg.slice!(0,500)
      privmsg msg, recipients if msg != ''
    end

    def quit message = nil
      write "QUIT :#{message}"
    end

    def pong value
      write "PONG #{value}"
    end

    def disconnect
      quit
      socket.close
    end

    def socket
      @socket ||= TCPSocket.open(@host, @port)
    end
    Thread.abort_on_exception = true

    def listen
      unless @listening
        loop do
          @listening = true
          socket.lines "\r\n" do |line|
            message = Message.new(line, self)
            Callback.handle message
          end
          @listening = false
        end
      end
    end
  end # class Connection
end
