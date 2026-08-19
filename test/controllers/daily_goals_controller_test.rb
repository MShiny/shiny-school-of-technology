require "test_helper"

class DailyGoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @goal = DailyGoal.create!(date: Date.current)
    @goal.daily_goal_items.create!(text: "Study today", position: 1)
  end

  test "index lists daily goals newest first" do
    older = DailyGoal.create!(date: Date.current - 1.day)
    older.daily_goal_items.create!(text: "Study yesterday", position: 1, completed: true)

    get daily_goals_url

    assert_response :success
    assert_equal [ @goal, older ], DailyGoal.recent.to_a
  end

  test "index shows completed / total item counts for each day" do
    @goal.daily_goal_items.first.update!(completed: true)
    @goal.daily_goal_items.create!(text: "Second item", position: 2, completed: false)

    get daily_goals_url

    assert_response :success
    assert_match "1 / 2 completed", response.body
  end

  test "show displays the checklist for that day" do
    get daily_goal_url(@goal)

    assert_response :success
    assert_match "Study today", response.body
  end

  test "show renders today's checklist as editable with add/edit/remove controls" do
    get daily_goal_url(@goal)

    assert_response :success
    assert_select "form[action=?]", daily_goal_items_path
  end

  test "show renders a historical checklist as read-only" do
    historical = DailyGoal.create!(date: Date.current - 2.days)
    historical.daily_goal_items.create!(text: "Old item", position: 1, completed: true)

    get daily_goal_url(historical)

    assert_response :success
    assert_match "Old item", response.body
    assert_select "form[action=?]", daily_goal_items_path, count: 0
  end

  test "update allows editing notes" do
    patch daily_goal_url(@goal), params: { daily_goal: { notes: "Some notes" } }

    assert_equal "Some notes", @goal.reload.notes
  end
end
