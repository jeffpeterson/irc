module IRC
  class Message
    attr_accessor :connection

    REGEX = /^
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
        (\ +(?<middle>[^:\r\n\ ][^\r\n\ ]*))*
        (\ *:(?<trailing>.+))?
      )
      \r\n$
    /xi

    REGEX.names.each do |name|
      define_method name do 
        self[name.to_s]
      end
    end


    def initialize message_string, connection
      @connection = connection
      @match = REGEX.match(message_string)
      @raw = message_string
    end

    def [] key
      @match[key.to_s]
    end

    def inspect
      @match.names.map{|n| "#{n}: #{@match[n].inspect}"}.join(", ")
    end

    def action
      @action ||= command.downcase.to_sym
    end

    def content
      @content ||= trailing || middle
    end

    def raw
      @raw
    end
  end # class Message
end
