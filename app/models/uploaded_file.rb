class UploadedFile < ApplicationRecord
  belongs_to :project

  belongs_to :project
  has_one_attached :content
end
