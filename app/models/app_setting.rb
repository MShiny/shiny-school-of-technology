class AppSetting < ApplicationRecord
  DEFAULT_DAILY_GOAL_TEXT = "Study for at least 30 minutes."

  validates :default_daily_goal, presence: true

  # This app has a single user, so settings are a single row rather than
  # a generic per-user preferences system.
  def self.instance
    first_or_create!(default_daily_goal: DEFAULT_DAILY_GOAL_TEXT)
  end
end
