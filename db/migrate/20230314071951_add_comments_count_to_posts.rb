class AddCommentsCountToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :comments_count, :integer, null: true
  end
end
