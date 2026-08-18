require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "root route loads the dashboard" do
    get root_url
    assert_response :success
  end

  test "visiting the dashboard creates today's goal from the default when missing" do
    AppSetting.instance.update!(default_daily_goal: "Practice today.")

    assert_difference("DailyGoal.count", 1) do
      get root_url
    end

    goal = DailyGoal.find_by(date: Date.current)
    assert_equal "Practice today.", goal.goal_text
    assert_equal "pending", goal.status
  end

  test "visiting the dashboard again does not create a second goal for today" do
    get root_url

    assert_no_difference("DailyGoal.count") do
      get root_url
    end
  end

  test "dashboard shows active degrees and in-progress courses" do
    degree = Degree.create!(name: "AI/ML Degree", status: "active")
    subject = Subject.create!(name: "Python")
    degree.subjects << subject
    course = subject.courses.create!(title: "Programming for Everybody", status: "in_progress")

    get root_url

    assert_match degree.name, response.body
    assert_match course.title, response.body
  end
end
