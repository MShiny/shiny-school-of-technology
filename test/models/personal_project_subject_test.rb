require "test_helper"

class PersonalProjectSubjectTest < ActiveSupport::TestCase
  setup do
    @project = PersonalProject.create!(name: "LMS RAG Project")
    @subject = Subject.create!(name: "Python")
  end

  test "prevents linking the same subject to the same project twice" do
    PersonalProjectSubject.create!(personal_project: @project, subject: @subject)
    duplicate = PersonalProjectSubject.new(personal_project: @project, subject: @subject)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:subject_id], "is already linked to this project"
  end

  test "raises at the database level too, guarding against race conditions" do
    PersonalProjectSubject.create!(personal_project: @project, subject: @subject)

    assert_raises(ActiveRecord::RecordNotUnique) do
      PersonalProjectSubject.insert!({ personal_project_id: @project.id, subject_id: @subject.id })
    end
  end

  test "the same subject can be linked to different projects" do
    other_project = PersonalProject.create!(name: "Another Project")
    PersonalProjectSubject.create!(personal_project: @project, subject: @subject)

    assert PersonalProjectSubject.new(personal_project: other_project, subject: @subject).valid?
  end
end
