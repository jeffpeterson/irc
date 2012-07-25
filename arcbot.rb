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

mention_match /reload!/ do
  files = reload!
  reply "I reloaded #{files.map(&:inspect).to_sentence}."
end

mention_match /callbacks( (?<term>\S+))?/ do
  callbacks = []
  IRC::Callback.callbacks[:all].each do |callback|
    callbacks << %{#{callback.action}: "#{callback.regex.inspect}"}
  end
  callbacks.select! {|c| c[term] } if term

  response = ''
  response << "I have #{'callback'.pluralize(callbacks.count)}"
  response << " matching #{term.inspect}" if term
  response << "#{': ' + callbacks.to_sentence if callbacks.any?}."

  reply response
end

match /^ping (?<something>\S+)/ do
  `ping -c1 #{something}`
  case $?.exitstatus
  when 0
    reply "#{something} is up."
  when 68
    reply "#{something} is down."
  else
    reply "#{something} is not valid."
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


