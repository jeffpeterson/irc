require 'irc'

def norm word
  word.gsub(/(^[.!?]+)|([!?.]+$)/i,'').downcase
end

match /^(?!!kotw)(?<everything>.+)/ do
  words = everything.split(/ +/)
  words.each do |word|
    word = norm(word)
    store('kotw:word').zincrby word, 1, nick
  end
end

match /^!kotw +(?<word>[^ ]+)/ do
  self.word = norm(word)
  scores = store('kotw:word').zrevrange(word, 0, 0, with_scores: true)

  if !scores
    reply("I haven't seen anybody say '#{word}', yet.")
  else
    king, score = scores.first

    reply "#{king} is the king of '#{word}' and has said it #{'time'.pluralize(score.to_i)}", false
  end
end

mention_match /kotw count/ do

end
