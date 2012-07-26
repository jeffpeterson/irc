require 'irc'

def reload!
  self.class.reset!

  files = []
  Dir.glob("*bot.rb").each do |file|
    files << file
    load file
  end
  files
end

host  'dot'
port  6669

nick    'arcbot'
channel '#test'

mention_match /time/ do
  reply Time.now.strftime("it is %l:%M %P on %A, %B %-d, %Y.").gsub(/[ ]+/, ' ' )
end

match /(?<something>[^\.,!\?:]+) +(?<verb>is|are|am) +((?<del>not|n't) +)?(?<what>.+)$/i do
  self.something, self.verb = nick, 'is' if something.upcase == 'I'
  key = "factoid.#{something}"
  what.gsub!(/[\.!]+ *$/, '')

  if what !~ /\?+ *$/
    temp = false
    store.transaction do
      temp = store[key] ||= {verb:verb, what:[]}
      store[key][:what] << what if !store[key][:what].include?(what)
      store[key][:what].delete(what) if del
    end
    # reply "I stored #{something}: #{temp.inspect}"
  end
end

mention_match /forget (?<something>.+)/i do
  store.transaction do
    store.delete "factoid.#{something}"
  end

  reply "I forgot #{something}."
end

mention_match /wh(at|o) (is|are|am) (?<something>.+)\?/i do
  self.something = nick if something.upcase == 'I'
  what = store.get("factoid.#{something}")

  if !what
    reply %{I don't know anything about #{something}.}
  elsif something == nick
    reply "you are #{what[:what].to_sentence}."
  else
    reply "#{something} #{what[:verb]} #{what[:what].to_sentence}."
  end
  # reply "I read #{something}: #{what.inspect}"
end

mention_match /re(?<verb>load|boot|set)!/ do
  files = reload!
  reply "I re#{verb}#{'ed' if !verb['set']} #{files.map(&:inspect).to_sentence}."
end

mention_match /callbacks( *(with *)?(?<term>\S+))?/ do
  callbacks = []
  IRC::Callback.callbacks[:all].each do |callback|
    callbacks << %{#{callback.action}: "#{callback.regex.inspect}"}
  end

  callbacks.select! {|c| c[term] } if term

  response = ''
  response << "I have #{'callback'.pluralize(callbacks.count)}"
  response << " containing #{term.inspect}" if term
  response << ". I've sent them to you."

  reply response
  callbacks.each do |c|
    say c, nick
  end
end

match /^ping (?<something>.+)/ do
  sites = something.split(/[, ]+/)

  if sites.count > 5
    sites = []
    reply "I can't do that, #{nick}.", false
  end

  sites.each do |site|
    `ping -c1 #{site}`
    case $?.exitstatus
    when 0
      reply "#{site} is up."
    else
      reply "#{site} is down."
    end
  end
end

mention_match /join (?<chan>.+)/ do
  ch = chan.split(/[, ]+/)
  connection.join ch
  reply "I joined #{ch.to_sentence}."
end

mention_match /(?<verb>part|leave) (?<chan>.+)/ do
  ch, rejected = chan.split(/[, ]+/).partition {|c| c[0] == "#" && !self.class.channels.include?(c) }
  connection.part ch

  reply "I #{verb == 'leave' ? 'left' : 'parted'} #{ch.to_sentence}." if ch.any?
  reply "I'm sorry, I'm configured not to #{verb} #{rejected.to_sentence}." if rejected.any?
end

match /bot roll call/i do
  reply "arcbots, roll out!", false
end

start!
