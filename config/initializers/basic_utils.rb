module NumberUtils
  def to_time
    "#{self.to_i/3600}:#{self.to_i%3600/60}:#{(self-self.to_i/60*60).round(2)}"
  end
end

class Float
  include NumberUtils
end

class Fixnum
  include NumberUtils

  def to_size
    size = self * 1.0
    unit = 'B'
    if size > 1024
      size = size / 1024
      unit = 'K'
    end
    if size > 1024
      size = size / 1024
      unit = 'M'
    end
    if size > 1024
      size = size / 1024
      unit = 'G'
    end
    "#{size.round(2)}#{unit}"
  end
end

