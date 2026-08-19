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
end
