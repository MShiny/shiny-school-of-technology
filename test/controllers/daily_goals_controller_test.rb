require "test_helper"

class DailyGoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @goal = DailyGoal.create!(date: Date.current)
    @goal.daily_goal_items.create!(text: "Study today", position: 1)
  end

  # --- calendar (index) ---

  test "index renders the current month's calendar by default" do
    get daily_goals_url

    assert_response :success
    assert_match Date.current.strftime("%B %Y"), response.body
    assert_match Date.current.day.to_s, response.body
  end

  test "index renders a specific month via the month param" do
    get daily_goals_url(month: "2026-03")

    assert_response :success
    assert_match "March 2026", response.body
  end

  test "index falls back to the current month for an invalid month param" do
    get daily_goals_url(month: "not-a-month")

    assert_response :success
    assert_match Date.current.strftime("%B %Y"), response.body
  end

  test "index navigation links point to the previous and next month" do
    get daily_goals_url(month: "2026-03")

    assert_response :success
    assert_select "a[href=?]", daily_goals_path(month: "2026-02")
    assert_select "a[href=?]", daily_goals_path(month: "2026-04")
  end

  test "index handles the December to January year boundary" do
    get daily_goals_url(month: "2026-12")

    assert_response :success
    assert_select "a[href=?]", daily_goals_path(month: "2027-01")
    assert_select "a[href=?]", daily_goals_path(month: "2026-11")
  end

  test "index handles the January to December year boundary" do
    get daily_goals_url(month: "2027-01")

    assert_response :success
    assert_select "a[href=?]", daily_goals_path(month: "2026-12")
    assert_select "a[href=?]", daily_goals_path(month: "2027-02")
  end

  test "index links each date cell to its date-based show page" do
    get daily_goals_url(month: Date.current.strftime("%Y-%m"))

    assert_response :success
    assert_select "a[href=?]", daily_goal_path(Date.current.iso8601)
  end

  test "index does not create daily goals just by rendering the calendar" do
    assert_no_difference("DailyGoal.count") do
      get daily_goals_url
    end
  end

  # --- history (secondary list view) ---

  test "history lists daily goals newest first" do
    older = DailyGoal.create!(date: Date.current - 1.day)
    older.daily_goal_items.create!(text: "Study yesterday", position: 1, completed: true)

    get history_daily_goals_url

    assert_response :success
    assert_equal [ @goal, older ], DailyGoal.recent.to_a
  end

  test "history shows completed / total item counts for each day" do
    @goal.daily_goal_items.first.update!(completed: true)
    @goal.daily_goal_items.create!(text: "Second item", position: 2, completed: false)

    get history_daily_goals_url

    assert_response :success
    assert_match "1 / 2 completed", response.body
  end

  test "history does not include future planned dates" do
    future = DailyGoal.create!(date: Date.current + 3.days)
    future.daily_goal_items.create!(text: "Future item", position: 1)

    get history_daily_goals_url

    assert_response :success
    assert_no_match(/Future item/, response.body)
  end

  # --- show ---

  test "show displays the checklist for that day using a date-based URL" do
    get "/daily_goals/#{@goal.date.iso8601}"

    assert_response :success
    assert_match "Study today", response.body
  end

  test "show renders today's checklist as editable with add/edit/remove controls" do
    get daily_goal_url(@goal)

    assert_response :success
    assert_select "form[action=?]", daily_goal_items_path
  end

  test "show renders a historical checklist as editable too" do
    historical = DailyGoal.create!(date: Date.current - 2.days)
    historical.daily_goal_items.create!(text: "Old item", position: 1, completed: true)

    get daily_goal_url(historical)

    assert_response :success
    assert_match "Old item", response.body
    assert_select "form[action=?]", daily_goal_items_path
  end

  test "show creates a future daily goal on demand when visited for the first time" do
    DefaultGoalItem.create!(text: "Study Python", position: 1, active: true)
    future_date = Date.current + 4.days

    assert_difference("DailyGoal.count", 1) do
      get "/daily_goals/#{future_date.iso8601}"
    end

    assert_response :success
    goal = DailyGoal.find_by(date: future_date)
    assert_equal [ "Study Python" ], goal.daily_goal_items.map(&:text)
  end

  test "show creates a past daily goal on demand when visited for the first time" do
    DefaultGoalItem.create!(text: "Study Python", position: 1, active: true)
    past_date = Date.current - 15.days

    assert_difference("DailyGoal.count", 1) do
      get "/daily_goals/#{past_date.iso8601}"
    end

    assert_response :success
  end

  test "show does not duplicate an existing future daily goal on repeat visits" do
    future_date = Date.current + 4.days
    get "/daily_goals/#{future_date.iso8601}"

    assert_no_difference("DailyGoal.count") do
      get "/daily_goals/#{future_date.iso8601}"
    end
  end

  test "show displays a future daily goal as Planned" do
    future_date = Date.current + 2.days
    get "/daily_goals/#{future_date.iso8601}"

    assert_response :success
    assert_match "Planned", response.body
  end

  test "show returns not found for a malformed date" do
    get "/daily_goals/not-a-date"

    assert_response :not_found
  end

  # --- recurrence: three-layer population via the show action ---

  test "visiting a future Monday for the first time creates it from daily and Monday defaults only" do
    DefaultGoalItem.create!(text: "Study", position: 1, daily: true)
    DefaultGoalItem.create!(text: "DSA", position: 2, daily: false, weekdays: [ 1 ])
    DefaultGoalItem.create!(text: "Personal project", position: 3, daily: false, weekdays: [ 6 ])

    future_monday = Date.new(2026, 8, 31)

    get "/daily_goals/#{future_monday.iso8601}"

    assert_response :success
    assert_match "Study", response.body
    assert_match "DSA", response.body
    assert_no_match(/Personal project/, response.body)
  end

  test "recurring defaults alone do not mark an uncreated future date as planned on the calendar" do
    DefaultGoalItem.create!(text: "Study", position: 1, daily: true)
    DefaultGoalItem.create!(text: "DSA", position: 2, daily: false, weekdays: [ 1 ])

    get daily_goals_url(month: "2026-08")

    assert_response :success
    assert_no_match(/calendar-day--planned/, response.body)
  end

  test "clicking a future Monday and adding a date-specific item makes it Planned on the calendar" do
    DefaultGoalItem.create!(text: "Study", position: 1, daily: true)
    future_monday = Date.new(2026, 8, 31)

    get "/daily_goals/#{future_monday.iso8601}"
    goal = DailyGoal.find_by(date: future_monday)
    goal.daily_goal_items.create!(text: "Finish ML assignment", position: 2)

    get daily_goals_url(month: "2026-08")

    assert_response :success
    assert_match "calendar-day--planned", response.body
  end

  # --- update ---

  test "update allows editing notes" do
    patch daily_goal_url(@goal), params: { daily_goal: { notes: "Some notes" } }

    assert_equal "Some notes", @goal.reload.notes
  end

  test "update allows editing notes on a future daily goal" do
    future_date = Date.current + 3.days
    get "/daily_goals/#{future_date.iso8601}"

    patch "/daily_goals/#{future_date.iso8601}", params: { daily_goal: { notes: "Plan ahead" } }

    assert_equal "Plan ahead", DailyGoal.find_by(date: future_date).notes
  end
end
