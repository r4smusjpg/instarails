class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.references :user, foreign_key: true, null: false
      t.references :post, foreign_key: true, null: false    

      t.timestamps
    end

    add_index :likes, [:user_id, :post_id], unique: true,
                                            name: 'unique user_id/post_id pair'
  end
end
