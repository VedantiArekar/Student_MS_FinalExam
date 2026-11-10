# JSON API for students.
#
# It inherits from ActionController::API, a lightweight controller made for
# JSON APIs (no views, no cookies, no CSRF form tokens).
#
#   GET    /api/students?search=ali   index
#   GET    /api/students/:id          show
#   POST   /api/students              create
#   PATCH  /api/students/:id          update
#   DELETE /api/students/:id          destroy
module Api
  class StudentsController < ActionController::API
    before_action :set_student, only: %i[show update destroy]

    # ---------- Error handling: always answer with JSON ----------
    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Student not found." }, status: :not_found
    end

    rescue_from ActiveRecord::RecordNotUnique do
      render json: { errors: [ "Email has already been taken" ] }, status: 422
    end

    rescue_from ActionController::ParameterMissing do |error|
      render json: { errors: [ "Missing parameter: #{error.param}" ] }, status: :bad_request
    end

    # GET /api/students            -> all students
    # GET /api/students?search=ali -> students whose name contains "ali"
    def index
      students = Student.search_by_name(params[:search]).order(id: :desc)

      # "total" always counts ALL students (it is shown on the dashboard)
      render json: { total: Student.count, students: students }
    end

    # GET /api/students/1
    def show
      render json: { student: @student }
    end

    # POST /api/students
    def create
      student = Student.new(student_params)

      if student.save
        render json: { message: "Student added successfully.", student: student }, status: :created
      else
        render_validation_errors(student)
      end
    end

    # PATCH /api/students/1
    def update
      if @student.update(student_params)
        render json: { message: "Student updated successfully.", student: @student }
      else
        render_validation_errors(@student)
      end
    end

    # DELETE /api/students/1
    def destroy
      @student.destroy
      render json: { message: "Student deleted successfully." }
    end

    private

    def set_student
      @student = Student.find(params[:id])
    end

    # Strong parameters: only these four fields may be set from outside.
    def student_params
      params.require(:student).permit(:full_name, :email, :course, :semester)
    end

    # 422 = "Unprocessable": the data was received but is not valid.
    def render_validation_errors(student)
      render json: { errors: student.errors.full_messages }, status: 422
    end
  end
end
