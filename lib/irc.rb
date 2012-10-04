require 'irc/base'

class NewBot < IRC::Bot
  on(:ping) { connection.pong params}
end

module IRC
  module Delegator
    NewBot.public_methods.each do |method_name|
      define_method method_name do |*args, &block|
        NewBot.send method_name, *args, &block
      end
    end
  end
end

extend IRC::Delegator
