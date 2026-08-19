class DailyGoal < ApplicationRecord
  has_many :daily_goal_items, -> { ordered }, dependent: :destroy, inverse_of: :daily_goal

  validates :date, presence: true, uniqueness: true

  scope :recent, -> { order(date: :desc) }

  # Finds today's goal, creating it (with a snapshot of the currently active
  # default goal items) the first time it's needed. Only builds items on
  # creation, so once today's checklist exists, later edits to the defaults
  # or to today's own items never rewrite it.
  def self.find_or_create_today!
    find_by(date: Date.current) || create_with_default_items!(Date.current)
  end

  def self.create_with_default_items!(date)
    transaction do
      goal = create!(date: date)
      DefaultGoalItem.active.ordered.each do |default_item|
        goal.daily_goal_items.create!(text: default_item.text, position: default_item.position)
      end
      goal
    end
  end

  def historical?
    date < Date.current
  end

  def items_total
    daily_goal_items.size
  end

  def items_completed_count
    daily_goal_items.count { |item| item.completed? }
  end

  # A day counts toward the full-completion streak only when it has at
  # least one item and every item on it is completed.
  def fully_completed?
    items_total.positive? && items_completed_count == items_total
  end

  # Status is derived from the checklist rather than stored, so there's no
  # redundant state to keep in sync:
  # - "met"     -> every item completed.
  # - "partial" -> some, but not all, items completed.
  # - "not_met" -> zero items completed and the day is in the past (resolved).
  # - "pending" -> zero items completed but the day hasn't ended yet.
  def status
    return "met" if fully_completed?
    return "partial" if items_completed_count.positive?

    historical? ? "not_met" : "pending"
  end

  # Consecutive fully-completed days counting back from the given date.
  #
  # The given date's own completion decides where the count starts:
  # - fully completed     -> start counting from that date (included).
  # - not fully completed -> that date hasn't been resolved as a win, so
  #                          start counting from the day before instead of
  #                          zeroing out the streak (matches "today's
  #                          incomplete checklist must not break the
  #                          previous streak until the day is over").
  #
  # From the starting date, walk backward and stop at the first missing
  # date or the first day that isn't fully completed.
  def self.current_streak(as_of: Date.current)
    as_of_goal = includes(:daily_goal_items).find_by(date: as_of)
    start_date = as_of_goal&.fully_completed? ? as_of : as_of - 1.day

    goals_by_date = includes(:daily_goal_items).where("date <= ?", start_date).index_by(&:date)

    streak = 0
    date = start_date
    while goals_by_date[date]&.fully_completed?
      streak += 1
      date -= 1
    end
    streak
  end

  # Day-level stats (met/partial/not_met/pending counts and the classic
  # met-vs-resolved completion percentage), plus item-level stats: since a
  # day with 3 of 4 items completed shouldn't be treated the same as a day
  # with 0 of 4, the item completion percentage gives a more granular view
  # of the month than the day-level percentage alone.
  def self.monthly_stats(reference_date: Date.current)
    goals = includes(:daily_goal_items)
              .where(date: reference_date.beginning_of_month..reference_date.end_of_month)
              .to_a

    met = goals.count { |goal| goal.status == "met" }
    partial = goals.count { |goal| goal.status == "partial" }
    not_met = goals.count { |goal| goal.status == "not_met" }
    pending = goals.count { |goal| goal.status == "pending" }
    resolved = met + partial + not_met

    total_items = goals.sum(&:items_total)
    completed_items = goals.sum(&:items_completed_count)

    {
      met: met,
      partial: partial,
      not_met: not_met,
      pending: pending,
      total: goals.size,
      resolved: resolved,
      completion_percentage: resolved.zero? ? 0 : ((met.to_f / resolved) * 100).round,
      total_items: total_items,
      completed_items: completed_items,
      item_completion_percentage: total_items.zero? ? 0 : ((completed_items.to_f / total_items) * 100).round
    }
  end
end
