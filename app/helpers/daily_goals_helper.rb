module DailyGoalsHelper
  CALENDAR_DAY_CLASSES = {
    "met" => "calendar-day--met",
    "partial" => "calendar-day--partial",
    "not_met" => "calendar-day--not-met",
    "pending" => "calendar-day--pending",
    "planned" => "calendar-day--planned"
  }.freeze

  # A calendar cell's visual state comes straight from the goal's own
  # status (nil when no goal has been created for that date yet), so past,
  # today, and future dates are all handled by the same derived status.
  def calendar_day_class(goal)
    return "" if goal.nil?

    CALENDAR_DAY_CLASSES.fetch(goal.status, "")
  end
end
