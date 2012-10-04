Installation
============

Simply install the gem:

`gem install irc`

Usage
=====

Quickstart
----------

``` ruby
require 'irc'

host    'localhost'
nick    'MyBot'
channel '#MyChannel', '#OtherChannel'

# Say hi when somebody joins the channel:
on :join do
  say "Hi #{nick}!"
end

# Tell the time and date:
match /^!(?:time|now)/ do
  reply Time.now.strftime("it is %l:%M %P on %A, %B %-d, %Y.").gsub(/[ ]+/, ' ' )
end

start!
```
Then, `ruby newbot.rb`


Subclass
--------

Polluting the global namespace is bad.
Instead, you can `require 'irc/base'` and subclass `IRC::Bot`:

``` ruby
require 'irc/base'

class MyBot < IRC::Bot
 host    'localhost'
 nick    'MyBot'
 channel '#MyChannel'

 start!
end
```

You can re-load the bot to update its callbacks without disconnecting:
``` ruby
# mention_match requires messages to start with the name of the bot
mention_match /reload!/ do
  self.class.reset!

  load __FILE__
end
```
