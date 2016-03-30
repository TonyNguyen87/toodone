class CreateLists < ActiveRecord::Migration
  def up
    create_table :lists do |t|
      t.string :title, null: false
      t.integer :user_id
    end
  end

  def down
    drop_table :lists
  end
end
