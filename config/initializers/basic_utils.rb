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
end