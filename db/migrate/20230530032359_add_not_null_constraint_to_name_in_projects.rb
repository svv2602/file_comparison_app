class AddNotNullConstraintToNameInProjects < ActiveRecord::Migration[7.0]
  def change
    change_column :projects, :name, :string, null: false
  end
end
