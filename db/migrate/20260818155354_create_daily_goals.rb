class CreateDailyGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_goals do |t|
      t.date :date, null: false
      t.text :goal_text
      t.string :status, null: false, default: "pending"
      t.text :notes

      t.timestamps
    end

    add_index :daily_goals, :date, unique: true
  end
end
