module IRC
  class Callback
    attr_accessor :action, :regex

    def initialize action, regex = nil, factory = nil, &block
      @action  = action
      @regex = regex || //
      @block   = block
      @factory = factory
    end

    def call! message
      match = regex.match(message.content)
      return if !match

      (class << message; self; end).send :attr_accessor, *@regex.names

      match.names.each do |name|
        message.instance_variable_set("@#{name}", match[name])
      end

      Job.schedule do
        if @factory
          @factory.new(message).instance_eval(&@block)
        else
          @block.call(message, match)
        end
      end
    end

    class << self
      attr_accessor :callbacks, :filters

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

      def before action, &block
        filter :before, action, &block
      end

      def after action, &block
        filter :after, action, &block
      end

      def filter when, action, &block
        # filters[when] << 
      end

      def callbacks
        @callbacks ||= Hash.new {|hash,key| hash[key] = []}
      end

      def filters
        @filters ||= Hash.new {|hash,key| hash[key] = Hash.new {|h,k| h[k] = []}}
      end

      def clear!
        @callbacks = nil
        callbacks
      end
    end # class << Callback
  end # class Callback
end
