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

  test "show groups courses into current, next up, completed, and other sections" do
    current = @subject.courses.create!(title: "Programming for Everybody", status: "in_progress", roadmap_position: 2)
    next_up = @subject.courses.create!(title: "Advanced Python", status: "planned", roadmap_position: 3)
    completed = @subject.courses.create!(title: "Python Basics", status: "completed", roadmap_position: 1)
    paused = @subject.courses.create!(title: "Old Course", status: "paused")

    get subject_url(@subject)

    assert_response :success
    [ current, next_up, completed, paused ].each do |course|
      assert_match course.title, response.body
    end
  end

  test "show orders next up courses by roadmap_position ascending with nulls last" do
    unpositioned = @subject.courses.create!(title: "Zzz Someday", status: "planned")
    second = @subject.courses.create!(title: "Second Course", status: "planned", roadmap_position: 2)
    first = @subject.courses.create!(title: "First Course", status: "planned", roadmap_position: 1)

    get subject_url(@subject)

    body = response.body
    first_index = body.index(first.title)
    second_index = body.index(second.title)
    unpositioned_index = body.index(unpositioned.title)

    assert_operator first_index, :<, second_index
    assert_operator second_index, :<, unpositioned_index
  end
end
