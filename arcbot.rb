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
port  6667

nick    'arcbot'
channel '#geekboy', '#test'

mention_match /time/ do
  reply Time.now.strftime("it is %l:%M %P on %A, %B %-d, %Y.").gsub(/[ ]+/, ' ' )
end

match /(?<something>[^\.!\?:]+) (?<verb>is|are|am) (?<what>[^\.!?]+)[^?]*$/i do
  s, v = something, verb
  s, v = nick, 'is' if verb.downcase == 'am' && something.upcase == 'I'

  key = "factoid.#{s}"
  temp = store[key] || {verb:v, what:[]}

  if !temp[:what].include?(what)
    temp[:what] << what
    store[key] = temp
  end
end

mention_match /forget (?<something>.+)/i do
  store["factoid.#{something}"] = nil
  reply "I forgot #{something}."
end

match /wh(at|o) (is|are|am) (?<something>.+)\?/i do
  s = something
  s = nick if something.downcase == 'i'
  what = store["factoid.#{s}"]
  if !what.nil?
    if s != nick
      reply "#{something} #{what[:verb]} #{what[:what].to_sentence}."
    else
      reply "you are #{what[:what].to_sentence}."
    end
  end
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
  response << "#{': ' + callbacks.to_sentence if callbacks.any?}."

  reply response
end

match /^ping (?<something>.+)/ do
  sites = something.split(/[, ]+/)

  if sites.count > 5
    sites = []
    reply "Hah. Good try, #{nick}.", false
  end

  sites.each do |site|
    `ping -c1 #{site}`
    case $?.exitstatus
    when 0
      reply "#{site} is up."
    when 68
      reply "#{site} is down."
    else
      reply "#{site} is not valid."
    end
  end
end

mention_match /join (?<chan>.+)/ do
  ch = chan.split(/[, ]+/)
  connection.join ch
  reply "I joined #{ch.to_sentence}."
end

mention_match /(part|leave) (?<chan>.+)$/ do
  ch, rejected = chan.split(/[, ]+/).partition {|c| c[0] == "#" && !channels.include?(c) }
  reply "matched"
  connection.part ch
  reply "I parted #{ch.to_sentence}."
  reply "I'm sorry, I'm configured not to part #{rejected.to_sentence}."
end

match /bot roll call/i do
  reply "arcbots, roll out!", false
end

start!
