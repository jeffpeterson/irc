require 'redis'

module IRC
  class Store
    attr_reader :store

    def initialize options = {}
      options = {:host => 'localhost', :port => 6379}.merge(options)
      @store = Redis.new options
    end

    def method_missing method_name, *args, &block
      store.send method_name, *args, &block
    end

    class << self
      attr_accessor :options
      def store
        @store ||= self.new options
      end

    end
  end
end
