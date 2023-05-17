require 'pdf/reader'
require_relative 'arr_const'

class PdfProcessor
  def initialize(blob_id)
    @pdf_blob = ActiveStorage::Blob.find(blob_id)
  end

  class << self
    def hash_itog(o1, o2)
      array_of_hashes1 = o1.data_to_hash
      array_of_hashes2 = o2.data_to_hash

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
            if !value.empty? && hash_in_arr2[key] == value
              hash_row2['sum'] += 1
            end

            hash_row2['line_num'] = j + 1
          end
          str1 = hash_in_arr1[:row]
          str2 = hash_in_arr2[:row]
          result_compare_strings = compare_strings(str1, str2)
          hash_row2['sum_all'] = result_compare_strings
          hash_row2['row2'] = "" if result_compare_strings == 0

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
      hash = find_key_in_hash(result, "arr_row2", "sum_all")
      hash_to_arr(hash)
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
            max_element = max_el_in_hash(value, key_max)
            result[i.to_s] = {
              "row1" => hash["row1"],
              "row2" => max_element
            }
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
    @pdf_blob.open do |file|
      PDF::Reader.new(file).pages.each do |_|
        count += 1
      end
    end
    count
  end

  def extract_table_data
    table_data = []

    @pdf_blob.open do |file|
      reader = PDF::Reader.new(file)

      # Извлекаем данные из таблицы на каждой странице
      reader.pages.each do |page|
        # Извлекаем строки таблицы с помощью регулярного выражения
        rows = page.text.scan(/.+$/)

        # Добавляем строки в общий массив
        rows.each do |row|
          table_data << row # if row =~ REG_VALUE_SIZE_TYPE1 || row =~ REG_VALUE_SIZE_TYPE2 || row =~ REG_VALUE_SIZE_TYPE3
        end
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
    #
    table_data = extract_table_data
    arr_str = []
    table_data.each do |row|
      arr_column = { :row => row, :problems => "" }
      columns = row.split(/\s+/)
      columns.each do |column|
        h = recognize_properties(column)
        if h == {}
          arr_column[:problems] = (arr_column[:problems] == "" ? column : "#{arr_column[:problems]} #{column}")
        else
          h.each do |key, value|
            arr_column[valid_key_for_hash(arr_column, key)] = value
          end
        end
      end
      arr_str << arr_column
    end
    return arr_str
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

