class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
      t.string :item, null: false
      t.date :due_date
      t.string :list_id
      t.boolean :completed, default: false
    end
  end

  def down
    drop_table :tasks
  end
end
