extend IRC::Bot

irc = IRC.connect('localhost', 6669)
irc.channel = "#bottest"

irc.puts "NICK arcbot",
         "USER arcbot localhost irc.petersonj.com :Arc Bot",
         "JOIN #{irc.channel}",
         "PRIVMSG #{irc.channel} :arcbot is here!"

