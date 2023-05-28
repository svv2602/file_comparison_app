class Project < ApplicationRecord
  belongs_to :user
  has_many :uploaded_files, dependent: :destroy

end
