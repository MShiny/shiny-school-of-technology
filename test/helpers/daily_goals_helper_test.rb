require "test_helper"

class DailyGoalsHelperTest < ActionView::TestCase
  include DailyGoalsHelper

  test "returns no class when there is no goal for the date" do
    assert_equal "", calendar_day_class(nil)
  end

  test "maps a fully completed day to the met class" do
    goal = DailyGoal.new(date: Date.current - 1.day)
    goal.daily_goal_items.build(text: "A", completed: true)

    assert_equal "calendar-day--met", calendar_day_class(goal)
  end

  test "maps a partially completed day to the partial class" do
    goal = DailyGoal.new(date: Date.current - 1.day)
    goal.daily_goal_items.build(text: "A", completed: true)
    goal.daily_goal_items.build(text: "B", completed: false)

    assert_equal "calendar-day--partial", calendar_day_class(goal)
  end

  test "maps a historical unresolved day to the not_met class" do
    goal = DailyGoal.new(date: Date.current - 1.day)
    goal.daily_goal_items.build(text: "A", completed: false)

    assert_equal "calendar-day--not-met", calendar_day_class(goal)
  end

  test "maps today's unfinished checklist to the pending class" do
    goal = DailyGoal.new(date: Date.current)
    goal.daily_goal_items.build(text: "A", completed: false)

    assert_equal "calendar-day--pending", calendar_day_class(goal)
  end

  test "maps a future day with a saved plan to the planned class" do
    goal = DailyGoal.new(date: Date.current + 2.days)
    goal.daily_goal_items.build(text: "A", completed: false)

    assert_equal "calendar-day--planned", calendar_day_class(goal)
  end
end
