class UploadedFile < ApplicationRecord
  belongs_to :project
  has_one_attached :content, dependent: :destroy # Для исходного файла
  has_one_attached :processed_file, dependent: :destroy # Для обработанного файла

  before_destroy :check_first_uploaded_file

  private

  def check_first_uploaded_file
    if project.uploaded_files.first == self
      project.destroy
    else
      content.purge if content.attached?
      processed_file.purge if processed_file.attached?
    end
  end

end
