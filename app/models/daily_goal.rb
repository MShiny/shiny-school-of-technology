class DailyGoal < ApplicationRecord
  enum :status, {
    pending: "pending",
    met: "met",
    not_met: "not_met"
  }, default: "pending", validate: true

  validates :date, presence: true, uniqueness: true

  scope :recent, -> { order(date: :desc) }

  # Finds today's goal, creating it from the current default goal text
  # the first time it's needed. Only sets attributes on creation, so
  # editing today's goal (or changing the default later) never rewrites
  # an existing record.
  def self.find_or_create_today!
    find_or_create_by!(date: Date.current) do |goal|
      goal.goal_text = AppSetting.instance.default_daily_goal
      goal.status = "pending"
    end
  end

  # Consecutive "met" days counting back from the given date, stopping
  # at the first date with no goal or a status other than "met".
  def self.current_streak(as_of: Date.current)
    goals_by_date = where("date <= ?", as_of).index_by(&:date)

    streak = 0
    date = as_of
    while goals_by_date[date]&.met?
      streak += 1
      date -= 1
    end
    streak
  end

  def self.monthly_stats(reference_date: Date.current)
    goals = where(date: reference_date.beginning_of_month..reference_date.end_of_month).to_a
    total = goals.size
    met = goals.count { |goal| goal.status == "met" }

    {
      met: met,
      total: total,
      completion_percentage: total.zero? ? 0 : ((met.to_f / total) * 100).round
    }
  end
end
