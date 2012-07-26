class MarkovChain
  
  def self.load(file)
    new(File.read(file))
  end

  def initialize(text)
    @words = Hash.new
    wordlist = text.split
    wordlist.each_with_index do |word, index|
      add(word, wordlist[index + 1]) if index < wordlist.size - 1
    end
  end

  def parse text
    
  end

  def add(word, next_word)
		# if next_word.present? && word.present?
	    @words[word] = Hash.new(0) if !@words[word]
	    @words[word][next_word] += 1
		# end
  end

  def get(word)
    return '' if !@words[word]
    followers = @words[word]
    sum = followers.inject(0) {|sum, kv| sum += kv[1] }
    random = rand(sum) + 1
    partial_sum = 0

    next_word = followers.find do |word, count|
      partial_sum += count
      partial_sum >= random
    end.first

    next_word
  end

  def random_word
    @words.keys[rand(@words.keys.size)]
  end

  def words(count = 1, start_word = nil)
    sentence = ''
    word = start_word || random_word
    count.times do
      sentence << word << ' '
      word = get(word)
    end

    sentence.strip.gsub(/[^A-Za-z\s]/, '')
  end

  def sentences(count = 1, start_word = nil)
    word = start_word || random_word
    sentences = ''
    until sentences.count('.') == count
      sentences << word << ' '
      word = get(word)
    end
    sentences.strip.split('. ').map(&:strip).map(&:capitalize).join('. ')
  end

  def paragraphs(count = 1, start_word = nil)
    paragraphs = []
    count.times do
      n = rand(3) <= 1 ? rand(2) + 1 : rand(5) + 5
      paragraphs << sentences(n)
    end
    paragraphs.join("\n\n")
  end
end
