class StudentsController < ApplicationController
  before_action :set_student, only: %i[ show edit update destroy ]

  # GET /students or /students.json
  def index
    @students = Student.all
    render json: @students, status: :ok
  end

  # GET /students/1 or /students/1.json
  def show
    render json: @student, status: :found
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
    render json: @student, status: :found 
  end

  # POST /students or /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: "Student was successfully created." }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: "Student was successfully updated." }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: "Student was successfully destroyed." }
      format.json { head :no_content, status: :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @error = {errorCode: "404", msg: "student with id: #{params[:id]} is not found"}
      begin
      @student = Student.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render json: @error, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def student_params
      params.require(:student).permit(:departmentId, :name, :rollNumber)
    end
end
