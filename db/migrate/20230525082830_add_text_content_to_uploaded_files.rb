class AddTextContentToUploadedFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :uploaded_files, :text_content, :text
  end
end
