require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "edit shows the current default goal" do
    AppSetting.instance.update!(default_daily_goal: "Read for 20 minutes.")

    get edit_settings_url

    assert_response :success
    assert_match "Read for 20 minutes.", response.body
  end

  test "update changes the default goal without touching existing daily goals" do
    AppSetting.instance.update!(default_daily_goal: "Original default")
    existing_goal = DailyGoal.create!(date: Date.current, goal_text: "Original default", status: "pending")

    patch settings_url, params: { app_setting: { default_daily_goal: "New default" } }

    assert_equal "New default", AppSetting.instance.reload.default_daily_goal
    assert_equal "Original default", existing_goal.reload.goal_text
  end
end
