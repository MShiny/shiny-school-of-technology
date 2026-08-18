require "test_helper"

class DegreesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @degree = Degree.create!(name: "AI/ML Degree", status: "active")
  end

  test "index lists degrees" do
    get degrees_url
    assert_response :success
  end

  test "show displays the degree" do
    get degree_url(@degree)
    assert_response :success
  end

  test "create with subject_ids associates the selected subjects" do
    python = Subject.create!(name: "Python")
    maths = Subject.create!(name: "Mathematics")

    assert_difference("Degree.count", 1) do
      post degrees_url, params: {
        degree: { name: "Backend Degree", status: "planned", subject_ids: [ python.id, maths.id ] }
      }
    end

    degree = Degree.order(:created_at).last
    assert_equal [ python.id, maths.id ].sort, degree.subject_ids.sort
  end

  test "update can change associated subjects" do
    python = Subject.create!(name: "Python")
    @degree.subjects << python

    patch degree_url(@degree), params: { degree: { subject_ids: [ "" ] } }

    assert_empty @degree.reload.subjects
  end

  test "destroy removes the degree" do
    assert_difference("Degree.count", -1) do
      delete degree_url(@degree)
    end
  end
end
