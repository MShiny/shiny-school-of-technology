require "test_helper"

class CourseTest < ActiveSupport::TestCase
  setup do
    @subject = Subject.create!(name: "Python")
  end

  test "is invalid without a title" do
    course = Course.new(subject: @subject)
    assert_not course.valid?
    assert_includes course.errors[:title], "can't be blank"
  end

  test "is invalid without a subject" do
    course = Course.new(title: "Programming for Everybody")
    assert_not course.valid?
    assert_includes course.errors[:subject], "must exist"
  end

  test "progress_percentage is optional" do
    course = Course.new(subject: @subject, title: "Programming for Everybody")
    assert course.valid?
  end

  test "progress_percentage must be between 0 and 100" do
    course = Course.new(subject: @subject, title: "Programming for Everybody", progress_percentage: 101)
    assert_not course.valid?

    course.progress_percentage = -1
    assert_not course.valid?

    course.progress_percentage = 50
    assert course.valid?

    course.progress_percentage = 0
    assert course.valid?

    course.progress_percentage = 100
    assert course.valid?
  end

  test "defaults to planned status" do
    course = Course.create!(subject: @subject, title: "Programming for Everybody")
    assert_equal "planned", course.status
  end
end
