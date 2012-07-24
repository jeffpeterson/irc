require 'irc'

  match /(hi|hey|hello)(.*)arcbot/i do
    say "Hi #{nick}."
  end
