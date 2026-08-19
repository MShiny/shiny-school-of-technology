class RemoveLegacyGoalFieldsAndAppSettings < ActiveRecord::Migration[8.0]
  def change
    # goal_text and status are now fully represented by daily_goal_items
    # (text per item) and derived from item completion, so keeping them
    # around would just be redundant state.
    remove_column :daily_goals, :goal_text, :text
    remove_column :daily_goals, :status, :string, default: "pending", null: false

    # The single default_daily_goal setting is replaced by the manageable
    # default_goal_items list.
    drop_table :app_settings do |t|
      t.text :default_daily_goal, null: false
      t.timestamps
    end
  end
end
