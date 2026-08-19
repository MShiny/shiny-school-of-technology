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

  # Consecutive "met" days counting back from the given date.
  #
  # Today's own status decides where the count starts:
  # - "met"      -> start counting from today (today included).
  # - "pending"  -> today hasn't been resolved yet, so start counting from
  #                 yesterday instead of zeroing out the streak.
  # - "not_met"  -> streak is broken, always 0.
  # - no record  -> treated like "pending" (nothing to break the streak yet).
  #
  # From the starting date, walk backward and stop at the first missing date
  # or the first non-"met" DailyGoal.
  def self.current_streak(as_of: Date.current)
    today_goal = find_by(date: as_of)
    return 0 if today_goal&.not_met?

    start_date = today_goal&.met? ? as_of : as_of - 1.day

    goals_by_date = where("date <= ?", start_date).index_by(&:date)

    streak = 0
    date = start_date
    while goals_by_date[date]&.met?
      streak += 1
      date -= 1
    end
    streak
  end

  # Pending goals are excluded from the completion percentage: only
  # "resolved" days (met or not_met) count toward the denominator, so an
  # unresolved today doesn't drag the month's percentage down.
  def self.monthly_stats(reference_date: Date.current)
    goals = where(date: reference_date.beginning_of_month..reference_date.end_of_month).to_a
    met = goals.count { |goal| goal.status == "met" }
    not_met = goals.count { |goal| goal.status == "not_met" }
    pending = goals.count { |goal| goal.status == "pending" }
    resolved = met + not_met

    {
      met: met,
      not_met: not_met,
      pending: pending,
      total: goals.size,
      resolved: resolved,
      completion_percentage: resolved.zero? ? 0 : ((met.to_f / resolved) * 100).round
    }
  end
end
