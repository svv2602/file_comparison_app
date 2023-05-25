require 'rtesseract'
require 'prawn'
require 'pdf/reader'
require 'fileutils'
require_relative 'text_processing'


class DocPdfOCR
  include TextProcessing
  def initialize(file_path, id_user = 1)
    @file_path = file_path
    @id_user = id_user
  end

  def self.remove_files_from_dir(id_user = 1)
    folder_path = "app/assets/temp/#{id_user}"
    if File.directory?(folder_path)
      # Удаляем все файлы в папке
      FileUtils.rm_rf(Dir.glob("#{folder_path}/*"))
      puts "Все файлы были удалены из папки #{folder_path}"
    else
      puts "Указанная папка #{folder_path} не существует"
    end
  end

  def basename_path
    file_directory = "app/assets/temp/#{@id_user}"
    unless File.directory?(file_directory)
      FileUtils.mkdir_p(file_directory)
    end
    file_directory + "/" + File.basename(@file_path, '.*') + '.'
  end

  def convert_pdf_to_img(extension = "jpg")
    file_extension = File.extname(@file_path).downcase

    if file_extension == ".pdf"
      hash = { "jpeg" => "jpeg", "png" => "png", "jpg" => "jpeg" }
      if hash.key?(extension)
        img_path = basename_path + extension
        # result = `pdftoppm -#{hash[extension]} #{file_path} #{img_path} 2>&1`
        result = system("pdftoppm -#{hash[extension]} #{@file_path} #{img_path} 2>&1")
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
    return img_path
  end

  def create_pdf_with_ocr

    unless contains_text?
      file_path = convert_pdf_to_img.gsub(/jpg/, "jpg-1.jpg")
      pdf_path = basename_path + 'pdf'
      image_text = RTesseract.new(file_path).to_s
      image_text = process_text_content(image_text)

      Prawn::Document.generate(pdf_path) do
        text image_text
      end

      # puts "Файл PDF с распознанным текстом успешно создан: #{pdf_path}"
      pdf_path
    else
      false
    end

  end

  def create_txt_with_ocr
    unless contains_text?
      file_path = convert_pdf_to_img.gsub(/jpg/, "jpg-1.jpg")
      txt_path = basename_path + 'txt'
      image_text = RTesseract.new(file_path).to_s
      image_text = process_text_content(image_text)
      File.open(txt_path, 'w') do |file|
        file.write(image_text)
      end

      # puts "Текстовый документ с распознанным текстом успешно создан: #{txt_path}"
      txt_path
    else
      false
    end
  end



  def contains_text?
    contains_text = false

    reader = PDF::Reader.new(@file_path)

    reader.pages.each do |page|
      text = page.text
      if text.match?(/\S/) # Проверяем, содержит ли текст страницы непустые символы, отличные от пробелов
        contains_text = true
        break
      end
    end

    contains_text
  end

end

# file_path = "/home/user/Рабочий стол/новая_таможня/invoice.pdf"
# file_path = 'lib/servis_pdf/inv3a.pdf'
# file_path = 'lib/servis_pdf/invoice.pdf'
# doc_pdf_ocr = DocPdfOCR.new(file_path)
# puts doc_pdf_ocr.contains_text?
# puts doc_pdf_ocr.create_pdf_with_ocr



