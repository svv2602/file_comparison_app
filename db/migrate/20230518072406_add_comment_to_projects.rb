class AddCommentToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :comment, :text
  end
end
