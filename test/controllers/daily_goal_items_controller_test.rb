require "test_helper"

class DailyGoalItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @today = DailyGoal.create!(date: Date.current)
    @item = @today.daily_goal_items.create!(text: "Study Python", position: 1)
  end

  test "create adds an item to today's checklist" do
    assert_difference("@today.daily_goal_items.count", 1) do
      post daily_goal_items_url, params: { daily_goal_item: { daily_goal_id: @today.id, text: "New item" } }
    end

    assert_redirected_to daily_goal_path(@today)
    assert_equal "New item", @today.daily_goal_items.order(:position).last.text
  end

  test "create does not add an incomplete item without text" do
    assert_no_difference("DailyGoalItem.count") do
      post daily_goal_items_url, params: { daily_goal_item: { daily_goal_id: @today.id, text: "" } }
    end
  end

  test "update edits an item's text on today's checklist" do
    patch daily_goal_item_url(@item), params: { daily_goal_item: { text: "Updated text" } }

    assert_equal "Updated text", @item.reload.text
  end

  test "toggle marks an item completed" do
    patch toggle_daily_goal_item_url(@item)
    assert @item.reload.completed?

    patch toggle_daily_goal_item_url(@item)
    assert_not @item.reload.completed?
  end

  test "toggling one item does not affect other items" do
    other = @today.daily_goal_items.create!(text: "Practice DSA", position: 2, completed: false)

    patch toggle_daily_goal_item_url(@item)

    assert @item.reload.completed?
    assert_not other.reload.completed?
  end

  test "destroy removes an item from today's checklist" do
    assert_difference("DailyGoalItem.count", -1) do
      delete daily_goal_item_url(@item)
    end
  end

  # --- historical dates are now editable too (V1.6) ---

  test "create adds an item to a historical daily goal" do
    historical = DailyGoal.create!(date: Date.current - 1.day)

    assert_difference("DailyGoalItem.count", 1) do
      post daily_goal_items_url, params: { daily_goal_item: { daily_goal_id: historical.id, text: "Retroactive item" } }
    end
  end

  test "update edits a historical daily goal's item" do
    historical = DailyGoal.create!(date: Date.current - 1.day)
    historical_item = historical.daily_goal_items.create!(text: "Old item", position: 1)

    patch daily_goal_item_url(historical_item), params: { daily_goal_item: { text: "Rewritten" } }

    assert_equal "Rewritten", historical_item.reload.text
  end

  test "toggle marks a historical daily goal's item completed" do
    historical = DailyGoal.create!(date: Date.current - 1.day)
    historical_item = historical.daily_goal_items.create!(text: "Old item", position: 1, completed: false)

    patch toggle_daily_goal_item_url(historical_item)

    assert historical_item.reload.completed?
  end

  test "destroy removes a historical daily goal's item" do
    historical = DailyGoal.create!(date: Date.current - 1.day)
    historical_item = historical.daily_goal_items.create!(text: "Old item", position: 1)

    assert_difference("DailyGoalItem.count", -1) do
      delete daily_goal_item_url(historical_item)
    end
  end

  # --- future dates are fully editable too ---

  test "create adds an item to a future daily goal" do
    future = DailyGoal.create!(date: Date.current + 3.days)

    assert_difference("DailyGoalItem.count", 1) do
      post daily_goal_items_url, params: { daily_goal_item: { daily_goal_id: future.id, text: "Plan ahead" } }
    end
  end

  test "update edits a future daily goal's item" do
    future = DailyGoal.create!(date: Date.current + 3.days)
    future_item = future.daily_goal_items.create!(text: "Draft plan", position: 1)

    patch daily_goal_item_url(future_item), params: { daily_goal_item: { text: "Python" } }

    assert_equal "Python", future_item.reload.text
  end

  test "toggle marks a future daily goal's item completed" do
    future = DailyGoal.create!(date: Date.current + 3.days)
    future_item = future.daily_goal_items.create!(text: "Draft plan", position: 1)

    patch toggle_daily_goal_item_url(future_item)

    assert future_item.reload.completed?
  end

  test "destroy removes a future daily goal's item" do
    future = DailyGoal.create!(date: Date.current + 3.days)
    future_item = future.daily_goal_items.create!(text: "Draft plan", position: 1)

    assert_difference("DailyGoalItem.count", -1) do
      delete daily_goal_item_url(future_item)
    end
  end
end
