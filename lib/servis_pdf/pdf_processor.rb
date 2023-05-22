require 'pdf/reader'
require 'stringio'
require_relative 'arr_const'


class PdfProcessor
  def initialize(uploaded_file, str_start , str_end )
    @pdf_blob = uploaded_file
    @str_start = str_start.empty? ? 1 : str_start.to_i
    @str_end = str_end.empty? ? line_count_from_pdf(uploaded_file) : str_end.to_i
    puts "Debug str_end: #{@str_end}"

    raise ArgumentError, "str_start should be less than or equal to str_end" if @str_start > @str_end
  end



  def line_count_from_pdf(uploaded_file)
    count = 0
    puts "Debug count start: #{count}"
    reader = PDF::Reader.new(StringIO.new(uploaded_file.download))

    reader.pages.each do |page|

      rows = page.text.scan(/.+$/)
      puts "Debug count: #{count}"
      # Добавляем строки в общий массив
      rows.each do |row|
        count += 1
      end
    end
    count == 0 ? 1 :count

  end

  class << self
    def hash_itog(o1, o2)
      array_of_hashes1 = o1.data_to_hash
      array_of_hashes2 = o2.data_to_hash
      # puts "DEBUG array_of_hashes1 - #{array_of_hashes1}"
      # puts "DEBUG array_of_hashes2 - #{array_of_hashes2}"
      result = {}
      array_of_hashes1.each_with_index do |hash_in_arr1, i|
        hash_row1 = {}

        array_of_hashes2.each_with_index do |hash_in_arr2, j|

          hash_row2 = {
            'row2' => hash_in_arr2[:row],
            'sum' => 0,
            'sum_all' => 0
          }
          hash_in_arr1.each do |key, value|
            if !value.to_s.empty? && hash_in_arr2[key] == value
              hash_row2['sum'] += 1
            end

            hash_row2['line_num'] = j + 1
          end
          str1 = hash_in_arr1[:row]
          str2 = hash_in_arr2[:row]
          result_compare_strings = compare_strings(str1, str2)
          hash_row2['sum_all'] = result_compare_strings
          hash_row2['row2'] = "" if result_compare_strings == 0
          hash_row2['num_str1'] = hash_in_arr1[:num_str]
          hash_row2['num_str2'] = hash_in_arr2[:num_str]

          hash_row1["#{j + 1}"] = hash_row2
        end

        result["txt1_line_#{(i + 1)}"] = {
          'row1' => hash_in_arr1[:row],
          'line_num' => i + 1,
          'arr_row2' => hash_row1
        }
      end
      result
    end

    def match_result(o1, o2)
      result = hash_itog(o1, o2)
      result = find_key_in_hash(result, "arr_row2", "sum_all")

      result.each do |key, hash_in|
        hash_out = mark_common_words_with_html(hash_in["row1"],hash_in["row2"])
        hash_in["row1"] = hash_out[:str1]
        hash_in["row2"] = hash_out[:str2]
      end

      result
    end

    def mark_common_words_with_html(str1,str2)
      words1 = str1.split(/ /).reject(&:empty?).uniq
      words2 = str2.split(/ /).reject(&:empty?).uniq

      words1.each do |word|
        if words2.include?(word) && !word.match(/<span.*<\/span>/)
          marked_word = "<span style='color:red;'>#{word}</span>"
          str1 = str1.gsub(/(?<=\s|^)#{Regexp.escape(word)}(?=\s|$)/, marked_word)
          str2 = str2.gsub(/(?<=\s|^)#{Regexp.escape(word)}(?=\s|$)/, marked_word)
        end
      end

      { str1: str1, str2: str2 }
    end


    def max_el_in_hash (hash, key_max)
      # h - хеш, key_hash - ключ вложенного хеша, key_find - ключ для поиска
      max_element = nil
      max_sum = 0

      hash.each_value do |line|
        if line[key_max] >= max_sum
          max_sum = line[key_max]
          max_element = line
        end
      end

      max_element
    end

    def find_key_in_hash(hash_all, target_key, key_max)
      result = {}
      i = 1
      hash_all.each do |key, hash|
        hash.each do |key, value|
          if key == target_key
            max_element = {}
            max_element["row1"] = hash["row1"]

            hash_max_element = max_el_in_hash(value, key_max)
            hash_max_element.each do |key,value|
              max_element[key] = value
            end

            result[i.to_s] = max_element
          end

          if value.is_a?(Hash)
            find_key_in_hash(value, target_key, key_max)
          end
        end
        i += 1
      end
      result
    end

    def compare_strings(str1, str2)
      words1 = str1.split(/\W+/) # Разделение строки 1 на слова
      words2 = str2.split(/\W+/) # Разделение строки 2 на слова

      word_counts1 = count_word_occurrences(words1) # Подсчет использований слов в строке 1
      word_counts2 = count_word_occurrences(words2) # Подсчет использований слов в строке 2
      i = 0
      j = 0
      word_counts1.each do |word, count1|
        count2 = word_counts2[word] || 0 # Получение количества использований слова в строке 2
        pr = count2 == 0 ? 0 : (count2 > count1 ? 100 : 100 * count1.to_f / count2)
        i += pr
        j += 1
        # puts "Слово '#{word}': Строка 1 - #{count1} раз, Строка 2 - #{count2} раз, процент: #{pr}"
      end
      # puts "Процент по строке: #{i / j}" if j > 0
      j > 0 ? i / j : 0
    end

    def count_word_occurrences(words)
      word_counts = Hash.new(0)

      words.each do |word|
        next if word =~ /^\d+$/ || word.empty? || word =~ /#{VALUE_SERVICE_PARTS_ALL}/ || word =~ /#{VALUE_CURRENCY.join("|")}/
        word_counts[word] += 1
      end

      word_counts
    end

  end

  def count_pages
    count = 0
    @pdf_blob.download do |file|
      PDF::Reader.new(file).pages.each do |_|
        count += 1
      end
    end
    count
  end
  def contains_text?
    contains_text = false

    @pdf_blob.open do |file|
      reader = PDF::Reader.new(file)

      reader.pages.each do |page|
        text = page.text
        if text.match?(/\S/) # Проверяем, содержит ли текст страницы непустые символы, отличные от пробелов
          contains_text = true
          break
        end
      end
    end

    contains_text
  end

  def extract_table_data
    table_data = []

    reader = PDF::Reader.new(StringIO.new(@pdf_blob.download))

    # Извлекаем данные из таблицы на каждой странице
    reader.pages.each do |page|
      # Извлекаем строки таблицы с помощью регулярного выражения
      rows = page.text.scan(/.+$/)

      # Добавляем строки в общий массив
      rows.each do |row|
        table_data << row
      end
    end

    table_data
  end

  def recognize_properties(str)
    # создаем хеш по строке
    # ключи  HASH_PROPERTIES из arr_const, значение - результат регулярного выражения
    matches = {}
    HASH_PROPERTIES.each do |hash_property|
      hash_property.each do |key, value|
        if match = str.match(value)
          matches[key] = match[0] if !(key.to_s.include?("size_type") && match[0].size < 5)
        end
      end
    end
    return matches
  end

  def data_to_hash
    i = 0
    table_data = extract_table_data
    arr_str = []

    table_data.each do |row|
      i += 1

      if i <= @str_end && i >= @str_start
        arr_column = { row: row, problems: "", num_str: i }
        columns = row.split(/\s+/)

        columns.each do |column|
          h = recognize_properties(column)

          if h.empty?
            arr_column[:problems] = (arr_column[:problems].empty? ? column : "#{arr_column[:problems]} #{column}")
          else
            h.each do |key, value|
              arr_column[valid_key_for_hash(arr_column, key)] = value
            end
          end
        end

        arr_str << arr_column
      end
    end

    arr_str
  end

  def valid_key_for_hash(hash, key)
    k = 0
    if hash.key?(key)
      unless hash.key?("#{key}#{k}".to_s)
        k += 1
      end
    end
    k >= 1 ? "#{key}#{k}" : key
  end

end

