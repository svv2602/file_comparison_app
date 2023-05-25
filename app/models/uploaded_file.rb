class UploadedFile < ApplicationRecord
  belongs_to :project
  has_one_attached :content # Для исходного файла
  has_one_attached :processed_file # Для обработанного файла


end
