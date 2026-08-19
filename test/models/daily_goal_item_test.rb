require "test_helper"

class DailyGoalItemTest < ActiveSupport::TestCase
  setup do
    @goal = DailyGoal.create!(date: Date.current)
  end

  test "is invalid without text" do
    item = DailyGoalItem.new(daily_goal: @goal, position: 1)
    assert_not item.valid?
    assert_includes item.errors[:text], "can't be blank"
  end

  test "is invalid without a daily_goal" do
    item = DailyGoalItem.new(text: "Study", position: 1)
    assert_not item.valid?
    assert_includes item.errors[:daily_goal], "must exist"
  end

  test "defaults to not completed" do
    item = @goal.daily_goal_items.create!(text: "Study", position: 1)
    assert_equal false, item.completed
  end

  test "can be marked completed and incomplete independently of other items" do
    first = @goal.daily_goal_items.create!(text: "Study", position: 1, completed: true)
    second = @goal.daily_goal_items.create!(text: "Practice", position: 2, completed: false)

    first.update!(completed: false)

    assert_equal false, first.reload.completed
    assert_equal false, second.reload.completed
  end

  test "ordered scope sorts by position then id" do
    third = @goal.daily_goal_items.create!(text: "C", position: 3)
    first = @goal.daily_goal_items.create!(text: "A", position: 1)
    second = @goal.daily_goal_items.create!(text: "B", position: 2)

    assert_equal [ first, second, third ], @goal.daily_goal_items.ordered.to_a
  end
end
