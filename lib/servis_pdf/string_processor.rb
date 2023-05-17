require_relative 'arr_const'

class StringProcessor
  def initialize(str)
    @str = str
  end

  def puts_hash
    SIMPLE_HASH.each do |key,hash|
      hash.each do |key,value|
        puts "#{key}: #{value}"
      end
    end
  end



end

str = StringProcessor.new("str")
str.puts_hash