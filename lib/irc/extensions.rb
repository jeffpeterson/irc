class Array
  def to_sentence
    case length
    when 0
      ''
    when 1
      self[0].to_s
    when 2
      "#{self[0]} and #{self[1]}"
    else
      "#{self[0..-1].join(', ')}, and #{self.last}"
    end
  end
end

class Regexp
  def +(r)
    Regexp.new(source + r.source)
  end
end
