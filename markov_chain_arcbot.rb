require 'irc'

def add_text text
  wordlist = text.split

  wordlist.each_with_index do |word, index|
    add_word(word, wordlist[index + 1]) if index < wordlist.size - 1
  end
end

IRC::Store.transaction do
  IRC::Store[:markov_chain] = Hash.new unless IRC::Store.root?(:markov_chain)
end

def add_word word, next_word
  store.transaction do
    store[:markov_chain][word] = Hash.new(0) if !store[:markov_chain][word]
    store[:markov_chain][word][next_word] += 1
  end
end

def random_word
  words = store.get(:markov_chain)
  words.keys[rand(words.keys.size)]
end

def get_word word
  next_word = ''

  store.transaction do
    store.abort if !store[:markov_chain][word]

    followers = store[:markov_chain][word]
    sum = followers.inject(0) {|sum,kv| sum += kv[1]}
    random = rand(sum) + 1
    partial_sum = 0

    next_word = followers.find do |word, count|
      partial_sum += count
      partial_sum >= random
    end.first
  end

  next_word
end

def get_words count = 1, start_word = nil
  sentence = ''

  word = start_word || random_word
  count.times do
    sentence << word << ' '
    word = get_word(word)
  end

  sentence.strip.gsub(/[^A-Za-z\s]/, '')
end

def get_sentences count = 1, start_word = nil
  word = start_word || random_word
  sentences = ''
  until sentences.count('.') == count
    if word == ''
      word = random_word
      word += '.' if word !~ /[,.?!]$/i
    end
    sentences << word << ' '
    word = get_word(word)
  end
  sentences.strip.split('. ').map(&:strip).map(&:capitalize).join('. ')
end

on :privmsg do
  add_text content
end

mention_match /[^1-5]*(?<count>[1-5]) (?<type>sentence|word)(s)?( start(ing)? with (?<start_word>\w+))?/ do
  self.count = count.to_i

  case type
  when 'sentence'
    reply get_sentences(count, start_word), false
  when 'word'
    reply get_words(count, start_word), false
  end
end
