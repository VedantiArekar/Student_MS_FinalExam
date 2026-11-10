require "test_helper"

# Tests the JSON API from the outside, like the browser or curl would use it.
class StudentsApiTest < ActionDispatch::IntegrationTest
  setup do
    @alice = students(:alice)
  end

  test "GET /api/students returns all students and the total" do
    get "/api/students"

    assert_response :success
    body = response.parsed_body
    assert_equal 2, body["total"]
    assert_equal 2, body["students"].length
  end

  test "GET /api/students?search= filters by name but total counts everyone" do
    get "/api/students", params: { search: "ali" }

    assert_response :success
    body = response.parsed_body
    assert_equal [ "Alice Johnson" ], body["students"].map { |s| s["full_name"] }
    assert_equal 2, body["total"]
  end

  test "GET /api/students/:id returns one student" do
    get "/api/students/#{@alice.id}"

    assert_response :success
    assert_equal "alice@example.com", response.parsed_body["student"]["email"]
  end

  test "GET /api/students/:id answers 404 for an unknown id" do
    get "/api/students/0"

    assert_response :not_found
    assert_equal "Student not found.", response.parsed_body["error"]
  end

  test "POST /api/students creates a student" do
    assert_difference("Student.count", 1) do
      post "/api/students",
           params: { student: { full_name: "Carol White", email: "carol@example.com",
                                course: "Mathematics", semester: 2 } },
           as: :json
    end

    assert_response :created
    assert_equal "Student added successfully.", response.parsed_body["message"]
  end

  test "POST /api/students answers 422 with error messages for invalid data" do
    assert_no_difference("Student.count") do
      post "/api/students",
           params: { student: { full_name: "", email: "", course: "", semester: "" } },
           as: :json
    end

    assert_response 422
    errors = response.parsed_body["errors"]
    assert_includes errors, "Full name can't be blank"
    assert_includes errors, "Email can't be blank"
    assert_includes errors, "Course can't be blank"
    assert_includes errors, "Semester can't be blank"
  end

  test "POST /api/students rejects a duplicate email" do
    post "/api/students",
         params: { student: { full_name: "Another Alice", email: "ALICE@example.com",
                              course: "Physics", semester: 1 } },
         as: :json

    assert_response 422
    assert_includes response.parsed_body["errors"], "Email has already been taken"
  end

  test "POST /api/students without a student parameter answers 400" do
    post "/api/students", params: {}, as: :json

    assert_response :bad_request
  end

  test "PATCH /api/students/:id updates a student" do
    patch "/api/students/#{@alice.id}", params: { student: { course: "Physics" } }, as: :json

    assert_response :success
    assert_equal "Physics", @alice.reload.course
    assert_equal "Student updated successfully.", response.parsed_body["message"]
  end

  test "PATCH /api/students/:id answers 422 for invalid data" do
    patch "/api/students/#{@alice.id}", params: { student: { semester: 99 } }, as: :json

    assert_response 422
    assert_equal 3, @alice.reload.semester
  end

  test "DELETE /api/students/:id deletes a student" do
    assert_difference("Student.count", -1) do
      delete "/api/students/#{@alice.id}"
    end

    assert_response :success
    assert_equal "Student deleted successfully.", response.parsed_body["message"]
  end

  test "the health check /up answers 200" do
    get "/up"

    assert_response :success
  end

  test "the dashboard page loads" do
    get "/"

    assert_response :success
    assert_select "h1", "Student Management System"
  end
end
