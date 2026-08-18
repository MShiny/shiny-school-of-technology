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

  test "purpose is optional and persists free text" do
    course = Course.create!(subject: @subject, title: "Programming for Everybody")
    assert_nil course.purpose

    course.update!(purpose: "Complete Python E1 foundation")

    assert_equal "Complete Python E1 foundation", course.reload.purpose
  end

  test "level and purpose are independent fields" do
    course = Course.create!(
      subject: @subject,
      title: "Programming for Everybody",
      level: "E1",
      purpose: "Complete Python E1 foundation"
    )

    assert_equal "E1", course.level
    assert_equal "Complete Python E1 foundation", course.purpose
  end

  test "roadmap_position is optional" do
    course = Course.new(subject: @subject, title: "Advanced Python")
    assert course.valid?
    assert_nil course.roadmap_position
  end

  test "roadmap_position must be a positive integer when present" do
    course = Course.new(subject: @subject, title: "Advanced Python", roadmap_position: 0)
    assert_not course.valid?

    course.roadmap_position = -1
    assert_not course.valid?

    course.roadmap_position = 1.5
    assert_not course.valid?

    course.roadmap_position = 1
    assert course.valid?

    course.roadmap_position = 5
    assert course.valid?
  end

  test "roadmap_ordered sorts positioned courses first, then unpositioned, then by title" do
    unpositioned_b = Course.create!(subject: @subject, title: "Zzz Unpositioned")
    positioned_two = Course.create!(subject: @subject, title: "Second", roadmap_position: 2)
    unpositioned_a = Course.create!(subject: @subject, title: "Aaa Unpositioned")
    positioned_one = Course.create!(subject: @subject, title: "First", roadmap_position: 1)

    ordered = @subject.courses.roadmap_ordered.to_a

    assert_equal [ positioned_one, positioned_two, unpositioned_a, unpositioned_b ], ordered
  end
end
