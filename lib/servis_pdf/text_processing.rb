require 'rtesseract'
require 'stringio'
require 'pdf/reader'
module TextProcessing
  def process_text_content(image_text)
    image_text = image_text.gsub(/\n /, '').gsub(/\n+/, "\n").gsub(/_+/, " ").gsub(/US(S|s)/, "US$")
    image_text = image_text.gsub(/\$+/, '$').gsub("|", " ")
    image_text = image_text.gsub(/RI(?=\d|T)/, 'R1').gsub(/(?<=(R1))T/, '7').gsub(/(?<=(\d ))(i|I|1)s(?= \|)/, '18')
    image_text
  end
  def extract_table_data(file_content)
    table_data = []

    reader = PDF::Reader.new(StringIO.new(file_content))

    # Извлекаем данные из таблицы на каждой странице
    reader.pages.each do |page|
      # Извлекаем строки таблицы с помощью регулярного выражения
      rows = page.text.scan(/.+$/)
      # Добавляем строки в общий массив
      rows.each do |row|
        table_data << process_text_content(row)
      end
    end

    table_data.join("\n") # Объединяем все строки таблицы в одну строку
  end

end
