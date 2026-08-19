require "test_helper"

class DefaultGoalItemsControllerTest < ActionDispatch::IntegrationTest
  test "index lists default goal items" do
    DefaultGoalItem.create!(text: "Practice Python", position: 1)

    get default_goal_items_url

    assert_response :success
    assert_match "Practice Python", response.body
  end

  test "create adds a new default goal item" do
    assert_difference("DefaultGoalItem.count", 1) do
      post default_goal_items_url, params: { default_goal_item: { text: "Practice DSA", position: 1 } }
    end

    assert_redirected_to default_goal_items_path
  end

  test "create with blank text fails" do
    assert_no_difference("DefaultGoalItem.count") do
      post default_goal_items_url, params: { default_goal_item: { text: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "update edits an existing default goal item" do
    item = DefaultGoalItem.create!(text: "Practice Python", position: 1)

    patch default_goal_item_url(item), params: { default_goal_item: { text: "Practice more Python" } }

    assert_equal "Practice more Python", item.reload.text
  end

  test "toggle_active deactivates an active item" do
    item = DefaultGoalItem.create!(text: "Practice Python", position: 1, active: true)

    patch toggle_active_default_goal_item_url(item)

    assert_not item.reload.active?
  end

  test "toggle_active reactivates an inactive item" do
    item = DefaultGoalItem.create!(text: "Practice Python", position: 1, active: false)

    patch toggle_active_default_goal_item_url(item)

    assert item.reload.active?
  end

  test "destroy removes a default goal item" do
    item = DefaultGoalItem.create!(text: "Practice Python", position: 1)

    assert_difference("DefaultGoalItem.count", -1) do
      delete default_goal_item_url(item)
    end
  end

  test "editing defaults does not change an already-created daily goal's checklist" do
    default = DefaultGoalItem.create!(text: "Practice Python", position: 1)
    today = DailyGoal.find_or_create_today!

    patch default_goal_item_url(default), params: { default_goal_item: { text: "Something else entirely" } }

    assert_equal [ "Practice Python" ], today.reload.daily_goal_items.map(&:text)
  end
end
