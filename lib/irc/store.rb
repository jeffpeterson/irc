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

      def [] key
        store.transaction do
          store[key]
        end
      end

      def []= key, value
        store.transaction do
          store[key] = value
        end
      end

    end
  end
end
