class CreateDefaultGoalItems < ActiveRecord::Migration[8.0]
  def change
    create_table :default_goal_items do |t|
      t.string :text, null: false
      t.integer :position, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :default_goal_items, [ :active, :position ]
  end
end
