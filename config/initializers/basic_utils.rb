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

class Array
  def to_select_options(label_name = :name, value_name = :id)
    self.map do |e|
      e.is_a?(Hash) ? [e[label_name], e[value_name]] : [e.send(label_name), e.send(value_name)]
    end
  end
end