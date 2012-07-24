module IRC
  class Message
    attr_accessor :connection

    REGEX = /
      (:
        (?<prefix>
          (
            (?<servername>(?<nick>[a-z][a-z0-9\-\[\]\\`\^\{\}\.]*))
          )
          (!(?<user>[a-z0-9~]+))?
          (@(?<host>[a-z0-9\.]+))?
        )
        [\ ]+
      )?
      (?<command>[a-z]+|[0-9]{3})
      (?<params>
        \ 
        (
          :(?<trailing>.+)
        |
        )
      )
      \r\n
    /xi

    # :irc.petersonj.com 001 arcbot :Welcome to the Internet Relay Network arcbot!~arcbot@localhost

    REGEX.names.each do |name|
      define_method name do 
        self[name.to_s]
      end
    end


    def initialize message_string, connection
      @connection = connection
      @match = REGEX.match(message_string)
      @raw = message_string

      # puts  "<- " + inspect
    end

    def [] key
      @match[key.to_s]
    end

    def inspect
      @match.names.map{|n| "#{n}: #{@match[n].inspect}"}.join(", ")
    end

    def action
      command.downcase.to_sym
    end

    def content
      @content ||= params.gsub(/^[ ]*:/,'')
    end

    def raw
      @raw
    end
  end # class Message
end
