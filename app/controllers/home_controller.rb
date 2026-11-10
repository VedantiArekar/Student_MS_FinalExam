# Shows the dashboard page (HTML).
# All student data is loaded afterwards by JavaScript through the JSON API.
class HomeController < ApplicationController
  def index
    # Shown immediately; JavaScript keeps it up to date afterwards.
    @total_students = Student.count
  end
end
