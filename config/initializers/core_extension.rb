class String
  def numeric?
    Float(self)
    true
  rescue
    false
  end

  def to_bool
    return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

  def to_tsp
    ns = self.gsub("^ ^", '')
    size = ns.length
    return ns if size == 44
    if size < 44
      diff = 44 - size
      self.gsub!("^ ^", " " * diff)
    end
    self
  end
end

class Array
  def mean(method = nil)
    return 0 if size.zero?
    (method ? map(&method.to_sym).sum : sum)/size
  end
end

class Float
  def prettify
    to_i == self ? to_i : self
  end
end

class Range
  def intersection(other)
    return nil if (self.max < other.begin or other.max < self.begin)
    [self.begin, other.begin].max..[self.max, other.max].min
  end
  alias_method :&, :intersection
end
