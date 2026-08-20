class AddRecurrenceToDefaultGoalItems < ActiveRecord::Migration[8.0]
  def change
    # Existing (and, by default, newly quick-added) items behave exactly as
    # they always have -- applying every day -- unless someone opts a default
    # item into specific weekdays instead.
    add_column :default_goal_items, :daily, :boolean, default: true, null: false
    add_column :default_goal_items, :weekdays, :integer, array: true, default: [], null: false
  end
end
