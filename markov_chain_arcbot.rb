require 'irc'

def add_text text
  wordlist = text.split(/ +/)

  0.upto wordlist.length - 3  do |i|
    chunk = wordlist[i,i + 1].join(' ')
    puts "#{chunk.inspect} => #{wordlist[i+2].inspect}"
    add_word chunk, wordlist[i + 2]
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
  index = rand(store.zcard(word))
  store.zrange(word, index, index)
end

def get_words count = 1, start_word = nil
  sentence = []

  word = start_word || random_word
  count.times do
    sentence << word
    word = get_word(word)
  end

  sentence.strip.gsub(/[^A-Za-z\s]/, '')
end

def get_sentences count = 1, start_word = nil
  word = start_word || random_word
  sentences  = []
  until sentences.count >= count
    sentences << []

    while word
      sentences.last << word
      word = get_word(word)
    end

    word = random_word
  end

  sentences.map! do |s|
    s = s.join(' ')
    s[0] = s[0].upcase
    s << '.' if s !~ /[\.?!]+$/i
  end

  sentences.join(' ')
end

on :privmsg do
  add_text content
end

mention_match /random$/i do
  reply get_sentences
end

mention_match /[^1-5]*(?<count>[1-5]) (?<type>sentence|word)(s)?( start(ing)? with (?<start>.+))?/ do
  self.count = count.to_i
  self.start = nil if start !~ / /

  case type
  when 'sentence'
    reply get_sentences(count, start), false
  when 'word'
    reply get_words(count, start), false
  end
end
