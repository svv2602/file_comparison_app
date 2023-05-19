class Project < ApplicationRecord
  belongs_to :user
  has_many :uploaded_files
  # has_many_attached :files
end
