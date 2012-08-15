require 'irc'

def norm word
  word.gsub(/(^[.!?]+)|([!?.]+$)/i,'').downcase
end

match /^(?!!kotw)(?<everything>.+)/ do
  words = everything.split(/ +/)
  words.each do |word|
    word = norm(word)
    store('kotw:word').zincrby word, 1, (user || nick)
  end
end

match /^!kotw +(?<word>.+)$/ do
  self.word = norm(word)
  scores = store('kotw:word').zrevrange(word, 0, 0, with_scores: true)
  reply("I haven't seen anybody say '#{word}', yet.") and next if !scores

  king, score = scores.first

  reply "#{king} is the king of '#{word}' (#{score.to_i}).", false
end
