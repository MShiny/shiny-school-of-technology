require "test_helper"

class PersonalProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = PersonalProject.create!(name: "LMS RAG Project", status: "in_progress", goal: "Ship a RAG prototype.")
  end

  test "index lists personal projects" do
    get personal_projects_url
    assert_response :success
    assert_match @project.name, response.body
  end

  test "show displays the project and its subjects" do
    subject = Subject.create!(name: "Python")
    @project.subjects << subject

    get personal_project_url(@project)

    assert_response :success
    assert_match @project.goal, response.body
    assert_match subject.name, response.body
  end

  test "create with subject_ids associates the selected subjects" do
    python = Subject.create!(name: "Python")
    genai = Subject.create!(name: "Generative AI")

    assert_difference("PersonalProject.count", 1) do
      post personal_projects_url, params: {
        personal_project: {
          name: "New Project",
          status: "planned",
          goal: "Learn something new.",
          subject_ids: [ python.id, genai.id ]
        }
      }
    end

    project = PersonalProject.order(:created_at).last
    assert_equal [ python.id, genai.id ].sort, project.subject_ids.sort
  end

  test "create without a name fails validation" do
    assert_no_difference("PersonalProject.count") do
      post personal_projects_url, params: { personal_project: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "update can change status and associated subjects" do
    python = Subject.create!(name: "Python")
    @project.subjects << python

    patch personal_project_url(@project), params: {
      personal_project: { status: "completed", subject_ids: [ "" ] }
    }

    @project.reload
    assert_equal "completed", @project.status
    assert_empty @project.subjects
  end

  test "destroy removes the project" do
    assert_difference("PersonalProject.count", -1) do
      delete personal_project_url(@project)
    end
  end
end
