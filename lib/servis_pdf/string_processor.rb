# require_relative 'arr_const'

class StringProcessor
  attr_accessor :str

  def initialize(str)
    @str = str
  end

  def mark_common_words_with_html(str2)
    words1 = @str.split(/ /)
    words2 = str2.split(/ /)

    words1.each do |word|
      if words2.include?(word) && !word.match(/<span.*<\/span>/)
        marked_word = "<span style='color:red;'>#{word}</span>"
        @str = @str.gsub(/\b#{word}\b/, marked_word)
        str2 = str2.gsub(/\b#{word}\b/, marked_word)
      end
    end

    { str1: @str, str2: str2 }
  end

end

h ={
  "23"=>{"row1"=>"  385/55R22.5 20 NEO AllroadsT2 TL                               160K                 US$222.00",
         "row2"=>"             380/55R22.5 20 NEO AllroadsT TLS  20   PCS   US$222.00    US$4,440.00",
         "sum"=>5,
         "sum_all"=>80.0,
         "line_num"=>30},
  "25"=>{"row1"=>"  175/55R17 20 NEO AllroadsT2 TL                                         US$222.00",
         "row2"=>"             385/55R22.5 20 NEO AllroadsT2 TL  20   PCS   US$292.00    US$4,840.00",
         "sum"=>5,
         "sum_all"=>80.0,
         "line_num"=>30}
}


h.each do |key, hash_in|
  processor = StringProcessor.new(hash_in["row1"])
  result = processor.mark_common_words_with_html(hash_in["row2"])
  hash_in["row1"] = result[:str1]
  hash_in["row2"] = result[:str2]
end

puts h.inspect

