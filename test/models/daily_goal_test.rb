require "test_helper"

class DailyGoalTest < ActiveSupport::TestCase
  test "is invalid without a date" do
    goal = DailyGoal.new(goal_text: "Study")
    assert_not goal.valid?
    assert_includes goal.errors[:date], "can't be blank"
  end

  test "defaults to pending status" do
    goal = DailyGoal.create!(date: Date.current, goal_text: "Study")
    assert_equal "pending", goal.status
  end

  test "enforces one goal per calendar date via validation" do
    DailyGoal.create!(date: Date.current, goal_text: "Study")
    duplicate = DailyGoal.new(date: Date.current, goal_text: "Study more")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:date], "has already been taken"
  end

  test "enforces one goal per calendar date at the database level" do
    DailyGoal.create!(date: Date.current, goal_text: "Study")

    assert_raises(ActiveRecord::RecordNotUnique) do
      DailyGoal.insert!({ date: Date.current, goal_text: "Study more", status: "pending" })
    end
  end

  test "find_or_create_today! creates a goal copied from the current default" do
    AppSetting.instance.update!(default_daily_goal: "Read one chapter today.")

    goal = DailyGoal.find_or_create_today!

    assert_equal Date.current, goal.date
    assert_equal "Read one chapter today.", goal.goal_text
    assert_equal "pending", goal.status
  end

  test "find_or_create_today! does not duplicate or reset an existing goal for today" do
    existing = DailyGoal.create!(date: Date.current, goal_text: "Custom text", status: "met")

    found = DailyGoal.find_or_create_today!

    assert_equal existing.id, found.id
    assert_equal "Custom text", found.goal_text
    assert_equal "met", found.status
  end

  test "editing today's goal does not change the default setting" do
    AppSetting.instance.update!(default_daily_goal: "Original default")
    goal = DailyGoal.find_or_create_today!

    goal.update!(goal_text: "Something completely different")

    assert_equal "Original default", AppSetting.instance.reload.default_daily_goal
  end

  test "changing the default later does not alter existing daily goals" do
    AppSetting.instance.update!(default_daily_goal: "Original default")
    goal = DailyGoal.find_or_create_today!

    AppSetting.instance.update!(default_daily_goal: "A brand new default")

    assert_equal "Original default", goal.reload.goal_text
  end

  test "current_streak counts consecutive met days ending today" do
    today = Date.current
    DailyGoal.create!(date: today, status: "met", goal_text: "Study")
    DailyGoal.create!(date: today - 1.day, status: "met", goal_text: "Study")
    DailyGoal.create!(date: today - 2.days, status: "met", goal_text: "Study")
    DailyGoal.create!(date: today - 3.days, status: "not_met", goal_text: "Study")

    assert_equal 3, DailyGoal.current_streak(as_of: today)
  end

  test "current_streak stops at a missing date" do
    today = Date.current
    DailyGoal.create!(date: today, status: "met", goal_text: "Study")
    # today - 1.day intentionally missing
    DailyGoal.create!(date: today - 2.days, status: "met", goal_text: "Study")

    assert_equal 1, DailyGoal.current_streak(as_of: today)
  end

  test "current_streak is zero when the most recent date is not met" do
    today = Date.current
    DailyGoal.create!(date: today, status: "pending", goal_text: "Study")
    DailyGoal.create!(date: today - 1.day, status: "met", goal_text: "Study")

    assert_equal 0, DailyGoal.current_streak(as_of: today)
  end

  test "monthly_stats computes totals and completion percentage" do
    reference_date = Date.current.beginning_of_month + 5.days

    DailyGoal.create!(date: reference_date, status: "met", goal_text: "Study")
    DailyGoal.create!(date: reference_date + 1.day, status: "met", goal_text: "Study")
    DailyGoal.create!(date: reference_date + 2.days, status: "not_met", goal_text: "Study")
    DailyGoal.create!(date: reference_date + 3.days, status: "pending", goal_text: "Study")

    stats = DailyGoal.monthly_stats(reference_date: reference_date)

    assert_equal 2, stats[:met]
    assert_equal 4, stats[:total]
    assert_equal 50, stats[:completion_percentage]
  end
end
