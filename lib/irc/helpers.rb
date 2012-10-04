module IRC
  module Helpers
    def inflect noun, lookup = nil
      lookup ||= {
        'me'  => nick, 
        'you' => self.class.nick,
        nick  => 'you'
      }
      noun.gsub /[\w]+/i, lookup
    end
  end
end
