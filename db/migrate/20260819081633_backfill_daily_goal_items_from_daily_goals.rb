class BackfillDailyGoalItemsFromDailyGoals < ActiveRecord::Migration[8.0]
  # Minimal, migration-local models so this data migration keeps working even
  # if the real app models change shape (or the goal_text/status columns are
  # removed) in a later migration.
  class MigrationDailyGoal < ActiveRecord::Base
    self.table_name = "daily_goals"
  end

  class MigrationDailyGoalItem < ActiveRecord::Base
    self.table_name = "daily_goal_items"
  end

  def up
    MigrationDailyGoal.reset_column_information
    MigrationDailyGoal.find_each do |goal|
      next if MigrationDailyGoalItem.exists?(daily_goal_id: goal.id)

      text = goal.goal_text.presence || "Daily goal"
      completed = goal.status == "met"

      MigrationDailyGoalItem.create!(
        daily_goal_id: goal.id,
        text: text,
        position: 1,
        completed: completed
      )
    end
  end

  def down
    # Data migration only; nothing structural to reverse. Leaving the
    # backfilled items in place is safe and avoids destroying history.
  end
end
