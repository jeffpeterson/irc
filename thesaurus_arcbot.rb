require 'irc'
require 'json'
require 'net/http'

API_KEY = "c7583ecdd7049d52b99abd1601756606"

def lookup word
  if synonyms = store('thesaurus:synonyms').smembers(word)
    return synonyms
  end

  if synonyms = fetch_word(word)
    synonyms.each do |s|
      store('thesaurus:synonyms').sadd(word, s)
    end

    return synonyms
  end
  [word]
end

def fetch_word word
  begin
    json = Net::HTTP.get('words.bighugelabs.com', "/api/2/#{API_KEY}/#{word}/json")
  rescue
    return []
  end

  json = JSON.parse(json)
  synonyms = []

  json.each do |k,v|
    synonyms += v['syn']
  end

  synonyms
end

def thesaurize sentence
  self.sentence = sentence.split(/ +/i) unless sentence.is_a? Array
  sentence.map! do |word|
    word.gsub(/[a-z]+/i) do
      if synonyms = lookup(word)
        return synonyms.shuffle.first
      end

      word
    end
  end

  sentence.join(' ')
end

mention_match /thesaurize +(?<text>.+)/ do
  reply thesaurize(text).capitalize, false
end

match /!thesaurus +(?<words>.+)/ do
  words.split(/ +/).each do |word|
    reply lookup(word).to_sentence, false
  end
end
