require "test_helper"

class PersonalProjectTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    project = PersonalProject.new(status: "in_progress")
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "defaults to idea status" do
    project = PersonalProject.create!(name: "LMS RAG Project")
    assert_equal "idea", project.status
  end

  test "accepts all defined statuses" do
    project = PersonalProject.create!(name: "LMS RAG Project")

    %w[idea planned in_progress completed paused].each do |status|
      project.status = status
      assert project.valid?, "expected #{status} to be a valid status"
    end
  end

  test "rejects a status outside the defined list" do
    project = PersonalProject.create!(name: "LMS RAG Project")
    project.status = "archived"

    assert_not project.valid?
    assert_includes project.errors[:status], "is not included in the list"
  end

  test "can associate multiple subjects" do
    project = PersonalProject.create!(name: "LMS RAG Project", status: "in_progress")
    python = Subject.create!(name: "Python")
    genai = Subject.create!(name: "Generative AI")

    project.subjects << [ python, genai ]

    assert_equal 2, project.subjects.count
    assert_includes python.personal_projects, project
  end

  test "destroying a project removes its personal_project_subjects but not the subject" do
    project = PersonalProject.create!(name: "LMS RAG Project")
    subject = Subject.create!(name: "Python")
    project.subjects << subject

    assert_difference("PersonalProjectSubject.count", -1) do
      project.destroy
    end

    assert Subject.exists?(subject.id)
  end

  test "goal, target_date, and notes are optional free text/date fields" do
    project = PersonalProject.create!(
      name: "LMS RAG Project",
      goal: "Build a working RAG prototype that creates lesson plans from uploaded study material.",
      target_date: Date.current + 30.days,
      notes: "Started with a small local prototype."
    )

    assert project.valid?
    assert_equal Date.current + 30.days, project.target_date
  end
end
