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
      "#{self[0..-2].join(', ')}, and #{self.last}"
    end
  end
end

class String
  def pluralize number = 2
    case number
    when 0
      "no #{self}s"
    when 1
      "1 #{self}"
    else
      "#{number} #{self}s"
    end
  end
end

class Regexp
  def +(r)
    Regexp.new(source + r.source)
  end
end
