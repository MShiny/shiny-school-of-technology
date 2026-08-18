require "test_helper"

class DegreeSubjectTest < ActiveSupport::TestCase
  setup do
    @degree = Degree.create!(name: "AI/ML Degree")
    @subject = Subject.create!(name: "Python")
  end

  test "prevents linking the same subject to the same degree twice" do
    DegreeSubject.create!(degree: @degree, subject: @subject)
    duplicate = DegreeSubject.new(degree: @degree, subject: @subject)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:subject_id], "is already linked to this degree"
  end

  test "raises at the database level too, guarding against race conditions" do
    DegreeSubject.create!(degree: @degree, subject: @subject)

    assert_raises(ActiveRecord::RecordNotUnique) do
      DegreeSubject.insert!({ degree_id: @degree.id, subject_id: @subject.id })
    end
  end

  test "the same subject can be linked to different degrees" do
    other_degree = Degree.create!(name: "Backend Degree")
    DegreeSubject.create!(degree: @degree, subject: @subject)

    assert DegreeSubject.new(degree: other_degree, subject: @subject).valid?
  end
end
