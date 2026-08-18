require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subject = Subject.create!(name: "Python")
    @course = @subject.courses.create!(title: "Programming for Everybody", status: "in_progress")
  end

  test "index lists courses" do
    get courses_url
    assert_response :success
  end

  test "show displays the course" do
    get course_url(@course)
    assert_response :success
  end

  test "create with valid progress_percentage succeeds" do
    assert_difference("Course.count", 1) do
      post courses_url, params: {
        course: { subject_id: @subject.id, title: "New Course", status: "planned", progress_percentage: 50 }
      }
    end
  end

  test "create with out-of-range progress_percentage fails" do
    assert_no_difference("Course.count") do
      post courses_url, params: {
        course: { subject_id: @subject.id, title: "New Course", status: "planned", progress_percentage: 150 }
      }
    end
    assert_response :unprocessable_entity
  end

  test "destroy removes the course" do
    assert_difference("Course.count", -1) do
      delete course_url(@course)
    end
  end
end
