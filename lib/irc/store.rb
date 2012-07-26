require 'pstore'
require 'thread'

module IRC
  module Store
    class << self
      attr_accessor :store, :name

      def mutex
        @mutex ||= Mutex.new
      end

      def name
        @name ||= 'irc_bot.pstore'
      end

      def store
        @store ||= PStore.new name
      end

      def get key
        transaction do
          store[key]
        end
      end

      def set key, value
        transaction do
          store[key] = value
        end
      end

      def transaction *args, &block
        mutex.synchronize do
          store.transaction *args, &block
        end
      end

      def method_missing method_name, *args, &block
        store.send method_name, *args, &block
      end
    end
  end
end
