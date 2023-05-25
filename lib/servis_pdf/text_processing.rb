require 'rtesseract'

module TextProcessing
  def process_text_content(file_path)
    image_text = RTesseract.new(file_path).to_s
    image_text = image_text.gsub(/\n /, '').gsub(/\n+/, "\n").gsub(/_+/, " ").gsub(/US(S|s)/, "US$")
    image_text = image_text.gsub(/\$+/, '$').gsub("|", " ")
    image_text = image_text.gsub(/RI(?=\d|T)/, 'R1').gsub(/(?<=(R1))T/, '7').gsub(/(?<=(\d ))(i|I|1)s(?= \|)/, '18')
    image_text
  end
end
