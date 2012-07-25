require 'irc'

  match /^(hi|hey|hello)(.*)arcbot/i do
    reply "Hi #{nick}.", false
  end
