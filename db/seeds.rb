# Sample data for demonstration.
# Run with:  bin/rails db:seed
# It is safe to run more than once (existing emails are not duplicated).

sample_students = [
  { full_name: "Anna Schmidt",  email: "anna.schmidt@example.com",  course: "Computer Science",       semester: 2 },
  { full_name: "Ben Fischer",   email: "ben.fischer@example.com",   course: "Cybersecurity",          semester: 3 },
  { full_name: "Clara Weber",   email: "clara.weber@example.com",   course: "Data Science",           semester: 1 },
  { full_name: "David Müller",  email: "david.mueller@example.com", course: "Electrical Engineering", semester: 5 },
  { full_name: "Elena Wagner",  email: "elena.wagner@example.com",  course: "Business Informatics",   semester: 4 }
]

sample_students.each do |attributes|
  Student.find_or_create_by!(email: attributes[:email]) do |student|
    student.assign_attributes(attributes)
  end
end

puts "Seed finished. Total students: #{Student.count}"
