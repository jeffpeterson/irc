require 'irc'
require 'json'
require 'net/http'

API_KEY = "c7583ecdd7049d52b99abd1601756606"

def lookup word
  return synonyms if synonyms = store('thesaurus:synonyms').smembers(word)

  if synonyms = fetch_word(word)
    store('thesaurus:synonyms').sadd(word, *synonyms)
    synonyms
  end
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
  sentence = sentence.split(/ +/i) unless sentence.is_a? Array
  sentence.map! do |word|
    word.gsub(/[a-z]+/i) do
      if synonyms = lookup(word)
        return synonyms[0,3].shuffle.first
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
    reply lookup(word).to_sentence
  end
end
