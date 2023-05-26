require 'rtesseract'
require 'stringio'
require 'pdf/reader'
require 'prawn'
module TextProcessing
  def process_text_content(image_text)
    image_text = image_text.gsub(/\n /, '').gsub(/\n+/, "\n").gsub(/_+/, " ")
    image_text = image_text.gsub(/(?<=(\d ))(i|I|1)(s|g)(?= \|)/, '18')
    image_text = image_text.gsub(/RI(?=\d|T)/, 'R1').gsub(/(?<=(R1))T/, '7')
    image_text = image_text.gsub(/U(S|s){2}/, "US$")
    image_text = image_text.gsub(/(U|u)(S|s)\$/, "US$")
    image_text.gsub(/(?<=US\$)(i|I)/, '1')
    image_text.gsub(/(?<=US\$)(s|S|g)/, '8').gsub("|", " ")
    image_text.gsub(/(?<=\d{3}\/)T(?=.*(\d|O))/,"7")
    image_text
  end
  def extract_text(file_content)
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


  def create_pdf_from_text(uploaded_file)
    pdf = Prawn::Document.new
    pdf.text uploaded_file.text_content

    pdf_path = Rails.root.join('tmp', 'processed_pdf.pdf')
    pdf.render_file(pdf_path)

    # Создаем экземпляр `ActiveStorage::Blob` для PDF-файла
    processed_file_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(pdf_path),
      filename: 'processed_pdf.pdf',
      content_type: 'application/pdf'
    )

    uploaded_file.processed_file.purge # Удаляем существующий файл, если есть
    uploaded_file.processed_file.attach(processed_file_blob) # Прикрепляем новый файл

    # Удаляем временный файл PDF
    File.delete(pdf_path)
  end

end
