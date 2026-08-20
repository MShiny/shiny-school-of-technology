require "test_helper"

class DefaultGoalItemTest < ActiveSupport::TestCase
  test "is invalid without text" do
    item = DefaultGoalItem.new
    assert_not item.valid?
    assert_includes item.errors[:text], "can't be blank"
  end

  test "defaults to active" do
    item = DefaultGoalItem.create!(text: "Practice Python", position: 1)
    assert item.active?
  end

  test "can be deactivated without being deleted" do
    item = DefaultGoalItem.create!(text: "Practice Python", position: 1)
    item.update!(active: false)

    assert_not item.reload.active?
    assert DefaultGoalItem.exists?(item.id)
  end

  test "active scope only returns active items" do
    active_item = DefaultGoalItem.create!(text: "Practice Python", position: 1, active: true)
    DefaultGoalItem.create!(text: "Retired item", position: 2, active: false)

    assert_equal [ active_item ], DefaultGoalItem.active.to_a
  end

  test "ordered scope sorts by position ascending" do
    third = DefaultGoalItem.create!(text: "C", position: 3)
    first = DefaultGoalItem.create!(text: "A", position: 1)
    second = DefaultGoalItem.create!(text: "B", position: 2)

    assert_equal [ first, second, third ], DefaultGoalItem.ordered.to_a
  end

  test "automatically assigns the next position when none is given" do
    DefaultGoalItem.create!(text: "First", position: 5)
    item = DefaultGoalItem.create!(text: "Second")

    assert_equal 6, item.position
  end

  test "position must be a non-negative integer" do
    item = DefaultGoalItem.new(text: "Practice Python", position: -1)
    assert_not item.valid?
  end

  # --- recurrence: defaults / backfill ---

  test "new items default to daily recurrence" do
    item = DefaultGoalItem.create!(text: "Practice Python", position: 1)

    assert item.daily?
    assert_equal [], item.weekdays
  end

  # --- recurrence: applies_on? ---

  test "a daily item applies on every weekday" do
    item = DefaultGoalItem.create!(text: "Study", position: 1, daily: true)

    assert item.applies_on?(Date.new(2026, 8, 24)) # Monday
    assert item.applies_on?(Date.new(2026, 8, 30)) # Sunday
  end

  test "a Monday-only item applies on Monday but not Tuesday" do
    monday = Date.new(2026, 8, 24)
    tuesday = Date.new(2026, 8, 25)
    item = DefaultGoalItem.create!(text: "DSA practice", position: 1, daily: false, weekdays: [ 1 ])

    assert item.applies_on?(monday)
    assert_not item.applies_on?(tuesday)
  end

  test "a Mon/Wed/Fri item applies on all three days and not Thursday" do
    item = DefaultGoalItem.create!(text: "Math practice", position: 1, daily: false, weekdays: [ 1, 3, 5 ])

    assert item.applies_on?(Date.new(2026, 8, 24)) # Monday
    assert item.applies_on?(Date.new(2026, 8, 26)) # Wednesday
    assert item.applies_on?(Date.new(2026, 8, 28)) # Friday
    assert_not item.applies_on?(Date.new(2026, 8, 27)) # Thursday
  end

  test "an inactive recurring item never applies, even if the weekday matches" do
    item = DefaultGoalItem.create!(text: "Retired", position: 1, active: false, daily: false, weekdays: [ 1 ])

    assert_not item.applies_on?(Date.new(2026, 8, 24)) # Monday
  end

  # --- recurrence: validation ---

  test "an active item with daily false and no weekdays is invalid" do
    item = DefaultGoalItem.new(text: "Broken", position: 1, active: true, daily: false, weekdays: [])

    assert_not item.valid?
    assert_includes item.errors[:base], "must repeat daily or on at least one weekday"
  end

  test "an inactive item with no recurrence is still valid" do
    item = DefaultGoalItem.new(text: "Retired", position: 1, active: false, daily: false, weekdays: [])

    assert item.valid?
  end

  test "invalid weekday values are rejected" do
    item = DefaultGoalItem.new(text: "Bad weekday", position: 1, daily: false, weekdays: [ 9 ])

    assert_not item.valid?
    assert_includes item.errors[:weekdays], "must only contain valid weekdays"
  end

  test "weekday selections are cleared when daily is enabled" do
    item = DefaultGoalItem.create!(text: "Study", position: 1, daily: true, weekdays: [ 1, 2 ])

    assert_equal [], item.weekdays
  end

  test "blank checkbox-array entries are stripped from weekdays" do
    item = DefaultGoalItem.create!(text: "Math practice", position: 1, daily: false, weekdays: [ "", "1", "3" ])

    assert_equal [ 1, 3 ], item.weekdays
  end

  # --- recurrence: human-readable label ---

  test "recurrence_label describes a daily item" do
    item = DefaultGoalItem.new(daily: true)
    assert_equal "Every day", item.recurrence_label
  end

  test "recurrence_label describes a single weekday" do
    item = DefaultGoalItem.new(daily: false, weekdays: [ 1 ])
    assert_equal "Every Monday", item.recurrence_label
  end

  test "recurrence_label describes two weekdays with an ampersand, Monday-first ordered" do
    item = DefaultGoalItem.new(daily: false, weekdays: [ 0, 6 ])
    assert_equal "Saturday & Sunday", item.recurrence_label
  end

  test "recurrence_label abbreviates three or more weekdays" do
    item = DefaultGoalItem.new(daily: false, weekdays: [ 1, 3, 5 ])
    assert_equal "Mon, Wed, Fri", item.recurrence_label
  end
end
