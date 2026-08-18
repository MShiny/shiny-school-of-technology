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
    course = subject.courses.create!(title: "Programming for Everybody", status: "in_progress", purpose: "Complete Python E1 foundation")

    get root_url

    assert_match degree.name, response.body
    assert_match course.title, response.body
    assert_match course.purpose, response.body
  end

  test "dashboard shows in_progress and planned personal projects, prioritizing in_progress" do
    in_progress_project = PersonalProject.create!(name: "LMS RAG Project", status: "in_progress", goal: "Ship a RAG prototype.")
    planned_project = PersonalProject.create!(name: "Someday Project", status: "planned")
    PersonalProject.create!(name: "Old Idea", status: "idea")
    PersonalProject.create!(name: "Finished Project", status: "completed")

    get root_url

    assert_match in_progress_project.name, response.body
    assert_match planned_project.name, response.body
    assert_no_match(/Old Idea/, response.body)
    assert_no_match(/Finished Project/, response.body)

    in_progress_index = response.body.index(in_progress_project.name)
    planned_index = response.body.index(planned_project.name)
    assert_operator in_progress_index, :<, planned_index
  end

  test "dashboard shows an empty state when there are no active or planned personal projects" do
    get root_url

    assert_match "No active or planned personal projects", response.body
  end
end
