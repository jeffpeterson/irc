require 'irc'

KEY_LENGTHS = (2..10)

def add_text text
  wordlist = text.split(/ +/)

  KEY_LENGTHS.each do |key_length|
    (wordlist.length - key_length).times do |i|
      key   = wordlist[i,key_length].join(' ')
      value = wordlist[i + key_length]

      add_word key, value
    end
  end
end

def add_word word, next_word
  store.multi do
    store('markov:word').zincrby word, 1, next_word
    store('markov').sadd 'words', word
  end
end

def random_word
  store('markov').srandmember 'words'
end

def get_word word
  index = store('markov:word').zcard(word)
  return nil if index.zero?

  index = rand(index)
  store('markov:word').zrange(word, index, index).first
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
  reply "I've learned #{store('markov').scard('words')} words."
end

mention_match /[^1-5]*(?<count>[1-5]) *(?<type>sentence)s?( +start(ing)? +with +(?<start>.+ .+))?/ do
  self.count = self.count.to_i

  case type
  when 'sentence'
    reply get_sentences(count, start), false
  end
end

