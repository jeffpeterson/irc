module IRC
  class Callback
    attr_accessor :action, :regex

    def initialize action, regex = nil, factory = nil, &block
      @action  = action
      @regex   = regex || //
      @block   = block
      @factory = factory
    end

    def call! message
      if match = @regex.match(message.content)
        (class << message; self; end).send :attr_accessor, *@regex.names
        @regex.names.each do |name|
          message.instance_variable_set("@#{name}", match[name])
        end

        Thread.new do
        # begin
          if @factory
            @factory.new(message).instance_eval(&@block)
          else
            puts "calling #{@block}"
            @block.call(message, match)
          end
        end
      end
    end

    class << self
      attr_accessor :callbacks

      def handle message
        callbacks[message.action].each do |callback|
          callback.call! message
        end
      end

      def add action, *args, &block
        callback = new(action, *args, &block)

        callbacks[action] << callback
        callbacks[:all]   << callback
      end

      def callbacks
        @callbacks ||= Hash.new {|hash,key| hash[key] = []}
      end

      def reset!
        @callbacks = nil
        callbacks
      end
    end # class << Callback
  end # class Callback
end
