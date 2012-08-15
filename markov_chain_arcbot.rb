require 'irc'

def add_text text
  wordlist = text.split(/ +/)

  (wordlist.length - 2).times do |i|
    key   = wordlist[i,2].join(' ')
    value = wordlist[i + 2]

    add_word key, value
  end
end

def add_word word, next_word
  # store.sadd word, next_word # add the word to redis
  store.zincrby word, 1, next_word
  store.sadd "words:for:markov", word
end

def random_word
  store.srandmember "words:for:markov"
end

def get_word word
  # store.srandmember word
  index = store.zcard(word)
  return nil if index.zero?

  index = rand(index)
  store.zrange(word, index, index).first
end

def get_sentence start_word = nil
  word           = start_word || random_word
  sentence_array = word.split

  sentence_array = random_word.split while sentence_array.count < 2

  max   = 30
  count = 0

  while count < max && word = get_word(sentence_array[-2,2].join(' ')) do
    sentence_array << word
    count += 1
  end

  sentence = sentence_array.join(' ')
  sentence[0] = sentence[0].upcase
  sentence << '.' if sentence !~ /[\.?!]+$/i
  sentence
end

def get_sentences count = 1, start_word = nil
  sentences  = [get_sentence(start_word)]
  (count - 1).times do
    sentences << get_sentence
  end

  sentences.join(' ')
end

on :privmsg do
  add_text content
  # reply get_sentences(2) if rand(300) < 1
end

mention_match /random$/i do
  reply get_sentence
end

mention_match /markov words/i do
  reply "I've learned #{store.scard('words:for:markov')} words."
end

mention_match /[^1-5]*(?<count>[1-5]) *(?<type>sentence)s?( +start(ing)? +with +(?<start>.+ .+))?/ do
  self.count = self.count.to_i

  case type
  when 'sentence'
    reply get_sentences(count, start), false
  end
end

