require "test_helper"

class DailyGoalTest < ActiveSupport::TestCase
  test "is invalid without a date" do
    goal = DailyGoal.new
    assert_not goal.valid?
    assert_includes goal.errors[:date], "can't be blank"
  end

  test "enforces one goal per calendar date via validation" do
    DailyGoal.create!(date: Date.current)
    duplicate = DailyGoal.new(date: Date.current)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:date], "has already been taken"
  end

  test "enforces one goal per calendar date at the database level" do
    DailyGoal.create!(date: Date.current)

    assert_raises(ActiveRecord::RecordNotUnique) do
      DailyGoal.insert!({ date: Date.current })
    end
  end

  test "destroying a daily goal destroys its items" do
    goal = DailyGoal.create!(date: Date.current)
    goal.daily_goal_items.create!(text: "Study", position: 1)

    assert_difference("DailyGoalItem.count", -1) do
      goal.destroy
    end
  end

  # --- find_or_create_today! / default item snapshotting ---

  test "find_or_create_today! copies all currently active default items into today's checklist" do
    DefaultGoalItem.create!(text: "Study Python", position: 1, active: true)
    DefaultGoalItem.create!(text: "Practice DSA", position: 2, active: true)
    DefaultGoalItem.create!(text: "Retired item", position: 3, active: false)

    goal = DailyGoal.find_or_create_today!

    assert_equal Date.current, goal.date
    assert_equal [ "Study Python", "Practice DSA" ], goal.daily_goal_items.ordered.map(&:text)
    assert goal.daily_goal_items.none?(&:completed?)
  end

  test "find_or_create_today! does not duplicate or reset an existing goal for today" do
    existing = DailyGoal.create!(date: Date.current)
    existing.daily_goal_items.create!(text: "Custom item", position: 1, completed: true)

    found = DailyGoal.find_or_create_today!

    assert_equal existing.id, found.id
    assert_equal [ "Custom item" ], found.daily_goal_items.map(&:text)
  end

  test "find_or_create_for_date! creates a future date's checklist from active defaults" do
    DefaultGoalItem.create!(text: "Study Python", position: 1, active: true)
    DefaultGoalItem.create!(text: "Practice DSA", position: 2, active: true)

    future_date = Date.current + 5.days
    goal = DailyGoal.find_or_create_for_date!(future_date)

    assert_equal future_date, goal.date
    assert_equal [ "Study Python", "Practice DSA" ], goal.daily_goal_items.ordered.map(&:text)
  end

  test "find_or_create_for_date! creates a past date's checklist on demand without backfilling every day" do
    DefaultGoalItem.create!(text: "Study Python", position: 1, active: true)

    past_date = Date.current - 10.days
    assert_nil DailyGoal.find_by(date: past_date)

    goal = DailyGoal.find_or_create_for_date!(past_date)

    assert_equal past_date, goal.date
    assert_equal [ "Study Python" ], goal.daily_goal_items.map(&:text)
    assert_equal 1, DailyGoal.count
  end

  test "find_or_create_for_date! does not duplicate or reset an existing goal for that date" do
    future_date = Date.current + 2.days
    existing = DailyGoal.create!(date: future_date)
    existing.daily_goal_items.create!(text: "Custom future item", position: 1)

    found = DailyGoal.find_or_create_for_date!(future_date)

    assert_equal existing.id, found.id
    assert_equal [ "Custom future item" ], found.daily_goal_items.map(&:text)
  end

  test "a future date's saved plan is an independent snapshot from later default changes" do
    DefaultGoalItem.create!(text: "Original default", position: 1)
    future_date = Date.current + 4.days
    goal = DailyGoal.find_or_create_for_date!(future_date)

    DefaultGoalItem.first.update!(text: "Edited default text")
    DefaultGoalItem.create!(text: "A brand new default", position: 2)

    goal.reload
    assert_equal [ "Original default" ], goal.daily_goal_items.map(&:text)
  end

  test "customizing a future date's checklist does not affect another date" do
    tomorrow = DailyGoal.find_or_create_for_date!(Date.current + 1.day)
    day_after = DailyGoal.find_or_create_for_date!(Date.current + 2.days)

    tomorrow.daily_goal_items.create!(text: "Python", position: 1)
    tomorrow.daily_goal_items.create!(text: "Machine Learning", position: 2)

    day_after.daily_goal_items.create!(text: "Generative AI", position: 1)

    assert_equal [ "Python", "Machine Learning" ], tomorrow.reload.daily_goal_items.ordered.map(&:text)
    assert_equal [ "Generative AI" ], day_after.reload.daily_goal_items.ordered.map(&:text)
  end

  test "snapshot is independent: changing defaults later does not alter an existing day's checklist" do
    DefaultGoalItem.create!(text: "Original default", position: 1)
    goal = DailyGoal.find_or_create_today!

    DefaultGoalItem.create!(text: "A brand new default", position: 2)
    DefaultGoalItem.first.update!(text: "Edited default text")

    goal.reload
    assert_equal [ "Original default" ], goal.daily_goal_items.map(&:text)
  end

  test "customizing today's checklist does not modify the default template" do
    DefaultGoalItem.create!(text: "Study Python", position: 1)
    goal = DailyGoal.find_or_create_today!

    goal.daily_goal_items.create!(text: "Extra item added today", position: 2)
    goal.daily_goal_items.first.update!(completed: true)

    default = DefaultGoalItem.find_by(text: "Study Python")
    assert_equal "Study Python", default.text
    assert_equal 1, DefaultGoalItem.count
  end

  # --- status derivation ---

  test "status is met when every item is completed" do
    goal = DailyGoal.create!(date: Date.current)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: true)
    goal.daily_goal_items.create!(text: "B", position: 2, completed: true)

    assert_equal "met", goal.status
    assert goal.fully_completed?
  end

  test "status is partial when some but not all items are completed" do
    goal = DailyGoal.create!(date: Date.current)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: true)
    goal.daily_goal_items.create!(text: "B", position: 2, completed: false)

    assert_equal "partial", goal.status
    assert_not goal.fully_completed?
  end

  test "status is pending when today has zero completed items" do
    goal = DailyGoal.create!(date: Date.current)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: false)

    assert_equal "pending", goal.status
  end

  test "status is pending when today has no items at all" do
    goal = DailyGoal.create!(date: Date.current)

    assert_equal "pending", goal.status
  end

  test "status is not_met when a historical day has zero completed items" do
    goal = DailyGoal.create!(date: Date.current - 3.days)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: false)

    assert_equal "not_met", goal.status
  end

  test "status is not_met when a historical day has no items at all" do
    goal = DailyGoal.create!(date: Date.current - 3.days)

    assert_equal "not_met", goal.status
  end

  test "a historical day with partial completion still shows partial, not not_met" do
    goal = DailyGoal.create!(date: Date.current - 1.day)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: true)
    goal.daily_goal_items.create!(text: "B", position: 2, completed: false)

    assert_equal "partial", goal.status
  end

  test "status is planned for a future date regardless of completion" do
    goal = DailyGoal.create!(date: Date.current + 3.days)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: false)

    assert_equal "planned", goal.status
  end

  test "status is planned for a future date even when every item is completed" do
    goal = DailyGoal.create!(date: Date.current + 1.day)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: true)

    assert_equal "planned", goal.status
    assert goal.fully_completed?
  end

  test "status is planned for a future date with no items at all" do
    goal = DailyGoal.create!(date: Date.current + 1.day)

    assert_equal "planned", goal.status
  end

  test "future?, today?, and historical? correctly classify dates" do
    future = DailyGoal.create!(date: Date.current + 1.day)
    today = DailyGoal.create!(date: Date.current)
    past = DailyGoal.create!(date: Date.current - 1.day)

    assert future.future?
    assert_not future.historical?
    assert_not future.today?

    assert today.today?
    assert_not today.future?
    assert_not today.historical?

    assert past.historical?
    assert_not past.future?
    assert_not past.today?
  end

  test "items_total and items_completed_count reflect the checklist" do
    goal = DailyGoal.create!(date: Date.current)
    goal.daily_goal_items.create!(text: "A", position: 1, completed: true)
    goal.daily_goal_items.create!(text: "B", position: 2, completed: false)
    goal.daily_goal_items.create!(text: "C", position: 3, completed: true)

    assert_equal 3, goal.items_total
    assert_equal 2, goal.items_completed_count
  end

  # --- recent scope ---

  test "recent excludes future dates and orders past/today newest first" do
    future = DailyGoal.create!(date: Date.current + 2.days)
    today = DailyGoal.create!(date: Date.current)
    yesterday = DailyGoal.create!(date: Date.current - 1.day)

    assert_equal [ today, yesterday ], DailyGoal.recent.to_a
    assert_not_includes DailyGoal.recent.to_a, future
  end

  # --- current_streak ---

  test "current_streak counts consecutive fully-completed days ending today when today is fully completed" do
    today = Date.current
    [ today, today - 1.day, today - 2.days ].each do |date|
      goal = DailyGoal.create!(date: date)
      goal.daily_goal_items.create!(text: "Study", position: 1, completed: true)
    end
    broken = DailyGoal.create!(date: today - 3.days)
    broken.daily_goal_items.create!(text: "Study", position: 1, completed: false)

    assert_equal 3, DailyGoal.current_streak(as_of: today)
  end

  test "current_streak stops at a missing date" do
    today = Date.current
    goal = DailyGoal.create!(date: today)
    goal.daily_goal_items.create!(text: "Study", position: 1, completed: true)
    # today - 1.day intentionally missing
    older = DailyGoal.create!(date: today - 2.days)
    older.daily_goal_items.create!(text: "Study", position: 1, completed: true)

    assert_equal 1, DailyGoal.current_streak(as_of: today)
  end

  test "today's incomplete checklist (zero done) does not break the previous streak" do
    today = Date.current
    pending_today = DailyGoal.create!(date: today)
    pending_today.daily_goal_items.create!(text: "Study", position: 1, completed: false)

    [ today - 1.day, today - 2.days, today - 3.days, today - 4.days ].each do |date|
      goal = DailyGoal.create!(date: date)
      goal.daily_goal_items.create!(text: "Study", position: 1, completed: true)
    end

    assert_equal 4, DailyGoal.current_streak(as_of: today)
  end

  test "today's partial checklist does not break the previous streak" do
    today = Date.current
    partial_today = DailyGoal.create!(date: today)
    partial_today.daily_goal_items.create!(text: "A", position: 1, completed: true)
    partial_today.daily_goal_items.create!(text: "B", position: 2, completed: false)

    yesterday = DailyGoal.create!(date: today - 1.day)
    yesterday.daily_goal_items.create!(text: "Study", position: 1, completed: true)

    assert_equal 1, DailyGoal.current_streak(as_of: today)
  end

  test "current_streak treats a missing today the same as an incomplete today" do
    today = Date.current
    # no record for today at all
    [ today - 1.day, today - 2.days ].each do |date|
      goal = DailyGoal.create!(date: date)
      goal.daily_goal_items.create!(text: "Study", position: 1, completed: true)
    end

    assert_equal 2, DailyGoal.current_streak(as_of: today)
  end

  test "a fully-completed future plan does not inflate the current streak" do
    today = Date.current
    goal = DailyGoal.create!(date: today)
    goal.daily_goal_items.create!(text: "Study", position: 1, completed: true)

    future = DailyGoal.create!(date: today + 1.day)
    future.daily_goal_items.create!(text: "Study ahead", position: 1, completed: true)

    assert_equal 1, DailyGoal.current_streak(as_of: today)
  end

  test "a historical not_met day breaks the streak going forward from it" do
    today = Date.current
    goal = DailyGoal.create!(date: today)
    goal.daily_goal_items.create!(text: "Study", position: 1, completed: true)

    failed = DailyGoal.create!(date: today - 1.day)
    failed.daily_goal_items.create!(text: "Study", position: 1, completed: false)

    older = DailyGoal.create!(date: today - 2.days)
    older.daily_goal_items.create!(text: "Study", position: 1, completed: true)

    assert_equal 1, DailyGoal.current_streak(as_of: today)
  end

  # --- monthly_stats ---
  #
  # These are pinned to a fixed "today" via travel_to so the reference dates
  # (early in the month) are always historical, regardless of which day of
  # the real calendar month the suite happens to run on.

  test "monthly_stats computes day-level counts and completion percentage from resolved days only" do
    travel_to Date.new(2026, 6, 20) do
      reference_date = Date.current.beginning_of_month + 5.days

      met = DailyGoal.create!(date: reference_date)
      met.daily_goal_items.create!(text: "A", position: 1, completed: true)

      also_met = DailyGoal.create!(date: reference_date + 1.day)
      also_met.daily_goal_items.create!(text: "A", position: 1, completed: true)

      not_met = DailyGoal.create!(date: reference_date + 2.days)
      not_met.daily_goal_items.create!(text: "A", position: 1, completed: false)

      stats = DailyGoal.monthly_stats(reference_date: reference_date)

      assert_equal 2, stats[:met]
      assert_equal 1, stats[:not_met]
      assert_equal 3, stats[:total]
      assert_equal 3, stats[:resolved]
      assert_equal 67, stats[:completion_percentage]
    end
  end

  test "monthly_stats reports partial days separately from met and not_met" do
    travel_to Date.new(2026, 6, 20) do
      reference_date = Date.current.beginning_of_month + 5.days

      partial = DailyGoal.create!(date: reference_date)
      partial.daily_goal_items.create!(text: "A", position: 1, completed: true)
      partial.daily_goal_items.create!(text: "B", position: 2, completed: false)

      stats = DailyGoal.monthly_stats(reference_date: reference_date)

      assert_equal 1, stats[:partial]
      assert_equal 0, stats[:met]
      assert_equal 1, stats[:resolved]
      assert_equal 0, stats[:completion_percentage]
    end
  end

  test "monthly_stats computes item-level completion across all checklist items in the month" do
    travel_to Date.new(2026, 6, 20) do
      reference_date = Date.current.beginning_of_month + 5.days

      day_one = DailyGoal.create!(date: reference_date)
      day_one.daily_goal_items.create!(text: "A", position: 1, completed: true)
      day_one.daily_goal_items.create!(text: "B", position: 2, completed: true)
      day_one.daily_goal_items.create!(text: "C", position: 3, completed: false)

      day_two = DailyGoal.create!(date: reference_date + 1.day)
      day_two.daily_goal_items.create!(text: "A", position: 1, completed: true)

      stats = DailyGoal.monthly_stats(reference_date: reference_date)

      assert_equal 4, stats[:total_items]
      assert_equal 3, stats[:completed_items]
      assert_equal 75, stats[:item_completion_percentage]
    end
  end

  test "monthly_stats handles a day with zero items safely" do
    travel_to Date.new(2026, 6, 20) do
      reference_date = Date.current.beginning_of_month + 2.days
      DailyGoal.create!(date: reference_date)

      stats = DailyGoal.monthly_stats(reference_date: reference_date)

      assert_equal 0, stats[:total_items]
      assert_equal 0, stats[:completed_items]
      assert_equal 0, stats[:item_completion_percentage]
    end
  end

  test "monthly_stats excludes future dates within the same month from all calculations" do
    travel_to Date.new(2026, 6, 5) do
      met = DailyGoal.create!(date: Date.current - 1.day)
      met.daily_goal_items.create!(text: "A", position: 1, completed: true)

      future_planned = DailyGoal.create!(date: Date.current + 5.days)
      future_planned.daily_goal_items.create!(text: "B", position: 1, completed: true)
      future_planned.daily_goal_items.create!(text: "C", position: 2, completed: true)

      stats = DailyGoal.monthly_stats(reference_date: Date.current)

      assert_equal 1, stats[:met]
      assert_equal 1, stats[:total]
      assert_equal 1, stats[:resolved]
      assert_equal 100, stats[:completion_percentage]
      assert_equal 1, stats[:total_items]
      assert_equal 1, stats[:completed_items]
    end
  end

  test "monthly_stats handles no goals in the month safely" do
    reference_date = Date.current.beginning_of_month + 2.days

    stats = DailyGoal.monthly_stats(reference_date: reference_date)

    assert_equal 0, stats[:total]
    assert_equal 0, stats[:resolved]
    assert_equal 0, stats[:total_items]
    assert_equal 0, stats[:completion_percentage]
    assert_equal 0, stats[:item_completion_percentage]
  end
end
