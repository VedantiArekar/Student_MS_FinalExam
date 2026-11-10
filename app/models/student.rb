class Student < ApplicationRecord
  # Clean the input before it is validated,
  # e.g. "  Anna@Mail.COM " becomes "anna@mail.com".
  before_validation :clean_up_fields

  # ---------- Validations ----------
  validates :full_name, presence: true, length: { maximum: 100 }

  validates :email,
            presence: true,
            length: { maximum: 150 },
            format: { with: URI::MailTo::EMAIL_REGEXP,
                      message: "is not a valid email address",
                      allow_blank: true },
            uniqueness: { case_sensitive: false }

  validates :course, presence: true, length: { maximum: 100 }

  validates :semester, presence: true
  validates :semester,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 1,
                            less_than_or_equal_to: 12 },
            allow_nil: true

  # ---------- Search ----------
  # Finds students whose name contains the search text.
  # ILIKE = case-insensitive LIKE (PostgreSQL), so "ali" finds "Alice".
  # An empty search returns all students.
  def self.search_by_name(term)
    term = term.to_s.strip
    return all if term.empty?

    where("full_name ILIKE ?", "%#{sanitize_sql_like(term)}%")
  end

  private

  def clean_up_fields
    self.full_name = full_name.strip if full_name
    self.course    = course.strip if course
    self.email     = email.strip.downcase if email
  end
end
