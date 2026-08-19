class CreateDailyGoalItems < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_goal_items do |t|
      t.references :daily_goal, null: false, foreign_key: true
      t.string :text, null: false
      t.integer :position, null: false, default: 0
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :daily_goal_items, [ :daily_goal_id, :position ]
  end
end
