require 'pstore'

module IRC
  module Store
    class << self
      attr_accessor :store, :name

      def name
        @name ||= 'irc_bot.pstore'
      end

      def store
        @store ||= PStore.new name
      end

      def get key
        store.transaction do
          store[key]
        end
      end

      def set key, value
        store.transaction do
          store[key] = value
        end
      end

      def method_missing method_name, *args, &block
        store.send method_name, *args, &block
      end
    end
  end
end
