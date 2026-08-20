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

  test "create with weekday recurrence sets daily false and stores the selected weekdays" do
    post default_goal_items_url, params: {
      default_goal_item: { text: "DSA practice", daily: "0", weekdays: [ "", "1", "3" ] }
    }

    item = DefaultGoalItem.find_by!(text: "DSA practice")
    assert_not item.daily?
    assert_equal [ 1, 3 ], item.weekdays
  end

  test "create defaults to daily recurrence when no recurrence fields are submitted" do
    post default_goal_items_url, params: { default_goal_item: { text: "Practice Python", position: 1 } }

    item = DefaultGoalItem.find_by!(text: "Practice Python")
    assert item.daily?
  end

  test "create fails validation for an active item with no recurrence selected" do
    assert_no_difference("DefaultGoalItem.count") do
      post default_goal_items_url, params: {
        default_goal_item: { text: "Broken", daily: "0", weekdays: [ "" ] }
      }
    end
  end

  test "update can switch an item from daily to specific weekdays" do
    item = DefaultGoalItem.create!(text: "Study", position: 1, daily: true)

    patch default_goal_item_url(item), params: {
      default_goal_item: { daily: "0", weekdays: [ "", "6", "0" ] }
    }

    item.reload
    assert_not item.daily?
    assert_equal [ 6, 0 ], item.weekdays
  end

  test "update clears weekdays when switching an item back to daily" do
    item = DefaultGoalItem.create!(text: "DSA", position: 1, daily: false, weekdays: [ 1 ])

    patch default_goal_item_url(item), params: { default_goal_item: { daily: "1" } }

    assert_equal [], item.reload.weekdays
  end

  test "index displays each item's recurrence label" do
    DefaultGoalItem.create!(text: "Study", position: 1, daily: true)
    DefaultGoalItem.create!(text: "DSA", position: 2, daily: false, weekdays: [ 1, 3, 5 ])

    get default_goal_items_url

    assert_response :success
    assert_match "Every day", response.body
    assert_match "Mon, Wed, Fri", response.body
  end

  test "editing defaults does not change an already-created daily goal's checklist" do
    default = DefaultGoalItem.create!(text: "Practice Python", position: 1)
    today = DailyGoal.find_or_create_today!

    patch default_goal_item_url(default), params: { default_goal_item: { text: "Something else entirely" } }

    assert_equal [ "Practice Python" ], today.reload.daily_goal_items.map(&:text)
  end
end
