require "test_helper"

class DegreeTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    degree = Degree.new(status: "active")
    assert_not degree.valid?
    assert_includes degree.errors[:name], "can't be blank"
  end

  test "defaults to planned status" do
    degree = Degree.create!(name: "New Degree")
    assert_equal "planned", degree.status
  end

  test "can associate subjects through degree_subjects" do
    degree = Degree.create!(name: "AI/ML Degree", status: "active")
    subject = Subject.create!(name: "Python")

    degree.subjects << subject

    assert_includes degree.subjects, subject
    assert_includes subject.degrees, degree
  end

  test "destroying a degree removes its degree_subjects but not the subject" do
    degree = Degree.create!(name: "AI/ML Degree")
    subject = Subject.create!(name: "Python")
    degree.subjects << subject

    assert_difference("DegreeSubject.count", -1) do
      degree.destroy
    end

    assert Subject.exists?(subject.id)
  end
end
