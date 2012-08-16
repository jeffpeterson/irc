module IRC
  class Message
    REGEX = /^
      (:
        (?<prefix>
          (
            (?<servername>(?<nick>[a-z][a-z0-9_\-\[\]\\`\^\{\}\.\|]*))
          )
          (!(?<user>[a-z0-9~\.]+))?
          (@(?<host>[a-z0-9\.]+))?
        )
        [\ ]+
      )?
      (?<command>[a-z]+|[0-9]{3})
      (?<params>
        (\ +(?<middle>[^:\r\n\ ][^\r\n\ ]*))*
        (\ *:(?<trailing>.+))?
      )
      \r?\n$
    /xi

    attr_reader   :raw
    attr_accessor :connection
    attr_accessor *REGEX.names

    def initialize message_string, connection
      @raw = message_string

      @connection = connection
      @match = REGEX.match(message_string) || {}

      REGEX.names.each do |name|
        instance_variable_set("@#{name}", @match[name])
      end

    end

    def action
      @action ||= (command || '').downcase.intern
    end

    def content
      @content ||= trailing || middle
    end
  end # class Message
end
