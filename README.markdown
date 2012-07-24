Usage
=====
## Quickstart Method
``` ruby
require 'irc'

host    'localhost'
nick    'MyBot'
channel '#MyChannel'

# Say hi when somebody joins the channel:
on :join do
  say "Hi #{nick}!" if nick != 'MyBot'
end

# Tell the time and date
match /!time/ do
  reply Time.now.strftime("it is %l:%M %P on %A, %B %-d, %Y.").gsub(/[ ]+/, ' ' )
end

start!
```

## Sub-Class Method
``` ruby
require 'irc/base'

class MyBot < IRC::Bot
 host    'localhost'
 nick    'MyBot'
 channel '#MyChannel'

 start!
end
```

You can re-load the bot to update its callbacks:
``` ruby
# mention_match requires the name of the bot in a message
mention_match /reload!/ do
  self.class.reset!

  load __FILE__
end
```
