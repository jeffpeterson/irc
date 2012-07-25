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
channel '#geekboy'

mention_match /time/ do
  reply Time.now.strftime("it is %l:%M %P on %A, %B %-d, %Y.").gsub(/[ ]+/, ' ' )
end

# match /(?<something>.+) (?<article>is|are|am) (?<what>[^.]+)/ do
#   say "#{something} #{article} #{what}"
# end

mention_match /re(?<verb>load|boot|set)!/ do
  files = reload!
  reply "I re#{verb}#{'ed' if !verb['set']} #{files.map(&:inspect).to_sentence}."
end

mention_match /callbacks( (with )?(?<term>\S+))?/ do
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

mention_match /join (?<chan>#\S+)/ do
  
  connection.join ch = chan.split(',')
  reply "I joined #{ch.to_sentence}."
end

mention_match /(part|leave) (?<chan>#\S+)/ do
  connection.write "PART #{chan}"
  ch = chan.split(',')
  reply "I parted #{ch.to_sentence}."
end

start!


