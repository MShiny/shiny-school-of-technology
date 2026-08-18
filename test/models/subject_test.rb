require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    subject = Subject.new
    assert_not subject.valid?
    assert_includes subject.errors[:name], "can't be blank"
  end

  test "defaults to not_started status" do
    subject = Subject.create!(name: "Python")
    assert_equal "not_started", subject.status
  end

  test "can belong to multiple degrees" do
    subject = Subject.create!(name: "Python")
    degree_one = Degree.create!(name: "AI/ML Degree")
    degree_two = Degree.create!(name: "Backend Degree")

    subject.degrees << [ degree_one, degree_two ]

    assert_equal 2, subject.degrees.count
  end

  test "destroying a subject destroys its courses" do
    subject = Subject.create!(name: "Python")
    subject.courses.create!(title: "Programming for Everybody")

    assert_difference("Course.count", -1) do
      subject.destroy
    end
  end
end
