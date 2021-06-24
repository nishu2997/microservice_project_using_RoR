class DepartmentsController < ApplicationController
  before_action :set_department, only: %i[ show edit update destroy ]

  # GET /departments or /departments.json
  def index
    puts session[:_csrf_token]
    @departments = Department.all
    render json: @departments, status: :ok
  end

  # GET /departments/1 or /departments/1.json
  def show
    render json: @department, status: :found
  end

  # GET /departments/new
  def new
  end

  # GET /departments/1/edit
  def edit
    render json: @department, status: :found
  end

  # POST /departments or /departments.json
  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.html { redirect_to @department, notice: "Department was successfully created." }
        format.json { render :show, status: :created, location: @department }
      else 
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1 or /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to @department, notice: "Department was successfully updated." }
        format.json { render :show, status: :ok, location: @department }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1 or /departments/1.json
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to departments_url, notice: "Department was successfully destroyed." }
      format.json { head :no_content, status: :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @error = {errorCode: "404", msg: "department with id: #{params[:id]} is not found"}
      begin
      @department = Department.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render json: @error, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def department_params
      params.require(:department).permit(:departmentCode, :name)
    end
end
