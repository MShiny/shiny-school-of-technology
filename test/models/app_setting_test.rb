require "test_helper"

class AppSettingTest < ActiveSupport::TestCase
  test "instance creates a single row with the built-in default text on first access" do
    assert_equal 0, AppSetting.count

    setting = AppSetting.instance

    assert_equal 1, AppSetting.count
    assert_equal AppSetting::DEFAULT_DAILY_GOAL_TEXT, setting.default_daily_goal
  end

  test "instance reuses the existing row instead of creating another" do
    first_call = AppSetting.instance
    first_call.update!(default_daily_goal: "Custom goal")

    second_call = AppSetting.instance

    assert_equal 1, AppSetting.count
    assert_equal first_call.id, second_call.id
    assert_equal "Custom goal", second_call.default_daily_goal
  end

  test "is invalid without default_daily_goal" do
    setting = AppSetting.new(default_daily_goal: nil)
    assert_not setting.valid?
  end
end
