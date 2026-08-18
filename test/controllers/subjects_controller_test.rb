require "test_helper"

class SubjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subject = Subject.create!(name: "Python", status: "learning")
  end

  test "index lists subjects" do
    get subjects_url
    assert_response :success
  end

  test "show displays courses and degrees" do
    degree = Degree.create!(name: "AI/ML Degree")
    @subject.degrees << degree
    @subject.courses.create!(title: "Programming for Everybody", status: "in_progress")

    get subject_url(@subject)

    assert_response :success
    assert_match "Programming for Everybody", response.body
    assert_match degree.name, response.body
  end

  test "create with degree_ids associates the selected degrees" do
    degree = Degree.create!(name: "AI/ML Degree")

    assert_difference("Subject.count", 1) do
      post subjects_url, params: {
        subject: { name: "Deep Learning", status: "not_started", degree_ids: [ degree.id ] }
      }
    end

    subject = Subject.order(:created_at).last
    assert_equal [ degree.id ], subject.degree_ids
  end

  test "destroy removes the subject" do
    assert_difference("Subject.count", -1) do
      delete subject_url(@subject)
    end
  end

  test "show displays related personal projects" do
    project = PersonalProject.create!(name: "LMS RAG Project", status: "in_progress")
    project.subjects << @subject

    get subject_url(@subject)

    assert_response :success
    assert_match project.name, response.body
  end
end
