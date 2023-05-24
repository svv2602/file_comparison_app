require 'rtesseract'
require 'prawn'

class DocPdfOCR
  def basename_path(file_path)
    File.dirname(file_path) + '/' + File.basename(file_path, '.*') + '.'
  end

  def convert_pdf_to_img(file_path, extension = "jpg")
    file_extension = File.extname(file_path).downcase

    if file_extension == ".pdf"
      hash = { "jpeg" => "jpeg", "png" => "png", "jpg" => "jpeg" }
      if hash.key?(extension)
        img_path = basename_path(file_path) + extension
        result = `pdftoppm -#{hash[extension]} #{file_path} #{img_path} 2>&1`
        if $?.success?
          puts "PDF успешно преобразован в изображение"
        else
          puts "Ошибка при преобразовании PDF в изображение: #{result}"
        end
      else
        puts "Неизвестное расширение для выходного файла"
      end
    else
      puts "Неизвестный формат входного файла"
    end
  end

  def create_pdf_with_ocr(file_path)
    pdf_path = basename_path(file_path) + 'pdf'
    image_text = RTesseract.new(file_path).to_s
    image_text = image_text.gsub(/\n /, '').gsub(/\n+/, "\n").gsub(/_+/," ").gsub(/US(S|s)/,"US$")
    image_text = image_text.gsub(/\$+/, '$')
    image_text = image_text.gsub(/RI(?=\d|T)/, 'R1').gsub(/(?<=(R1))T/,'7').gsub(/(?<=(\d ))(i|I|1)s(?= \|)/,'18')
    puts image_text.inspect

    Prawn::Document.generate(pdf_path) do
      text image_text
    end

    puts "Файл PDF с распознанным текстом успешно создан: #{pdf_path}"
  end

end


