class AddProcessedFileToUploadedFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :uploaded_files, :processed_file, :binary
  end
end
