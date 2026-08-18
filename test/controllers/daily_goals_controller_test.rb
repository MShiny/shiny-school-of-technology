require "test_helper"

class DailyGoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @goal = DailyGoal.create!(date: Date.current, goal_text: "Study today", status: "pending")
  end

  test "index lists daily goals newest first" do
    older = DailyGoal.create!(date: Date.current - 1.day, goal_text: "Study yesterday", status: "met")

    get daily_goals_url

    assert_response :success
    assert_equal [ @goal, older ], DailyGoal.recent.to_a
  end

  test "mark_met updates status to met" do
    patch mark_met_daily_goal_url(@goal)
    assert_equal "met", @goal.reload.status
  end

  test "mark_not_met updates status to not_met" do
    patch mark_not_met_daily_goal_url(@goal)
    assert_equal "not_met", @goal.reload.status
  end

  test "reset returns status to pending" do
    @goal.update!(status: "met")
    patch reset_daily_goal_url(@goal)
    assert_equal "pending", @goal.reload.status
  end

  test "update allows editing historical goal text and notes" do
    patch daily_goal_url(@goal), params: { daily_goal: { goal_text: "Updated text", notes: "Some notes" } }

    @goal.reload
    assert_equal "Updated text", @goal.goal_text
    assert_equal "Some notes", @goal.notes
  end
end
