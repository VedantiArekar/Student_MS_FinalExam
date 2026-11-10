require "test_helper"

class StudentTest < ActiveSupport::TestCase
  def valid_attributes
    { full_name: "Carol White", email: "carol@example.com", course: "Mathematics", semester: 2 }
  end

  test "is valid with all required fields" do
    assert Student.new(valid_attributes).valid?
  end

  test "full_name is required" do
    student = Student.new(valid_attributes.merge(full_name: ""))
    assert_not student.valid?
    assert_includes student.errors[:full_name], "can't be blank"
  end

  test "email is required" do
    student = Student.new(valid_attributes.merge(email: ""))
    assert_not student.valid?
    assert_includes student.errors[:email], "can't be blank"
  end

  test "email must look like an email address" do
    student = Student.new(valid_attributes.merge(email: "not-an-email"))
    assert_not student.valid?
    assert_includes student.errors[:email], "is not a valid email address"
  end

  test "email must be unique, ignoring upper/lower case" do
    student = Student.new(valid_attributes.merge(email: "ALICE@example.com"))
    assert_not student.valid?
    assert_includes student.errors[:email], "has already been taken"
  end

  test "course is required" do
    student = Student.new(valid_attributes.merge(course: ""))
    assert_not student.valid?
    assert_includes student.errors[:course], "can't be blank"
  end

  test "semester is required" do
    student = Student.new(valid_attributes.merge(semester: nil))
    assert_not student.valid?
    assert_includes student.errors[:semester], "can't be blank"
  end

  test "semester must be a whole number between 1 and 12" do
    [ 0, 13, 2.5 ].each do |wrong_value|
      student = Student.new(valid_attributes.merge(semester: wrong_value))
      assert_not student.valid?, "semester #{wrong_value} should be invalid"
    end
  end

  test "spaces are removed and the email is saved in lower case" do
    student = Student.create!(valid_attributes.merge(full_name: "  Carol White ", email: " Carol@Example.COM "))
    assert_equal "Carol White", student.full_name
    assert_equal "carol@example.com", student.email
  end

  test "search_by_name finds partial matches ignoring case" do
    assert_equal [ students(:alice) ], Student.search_by_name("ALI").to_a
  end

  test "search_by_name with an empty text returns every student" do
    assert_equal 2, Student.search_by_name("  ").count
  end

  test "search_by_name returns nothing when no name matches" do
    assert_empty Student.search_by_name("zzz")
  end
end
