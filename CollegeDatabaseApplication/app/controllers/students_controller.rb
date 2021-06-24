require 'faraday'
require 'circuitbox/faraday_middleware'
class StudentsController < ApplicationController
    include StudentsHelper
    before_action :set_student_id, only: [:show, :edit, :update, :destroy]
    before_action :set_conn
    before_action :set_conn_with_department

    def index
        begin
            response = @conn.get "/students"
            @students = JSON.parse response.body
        rescue => e
            render template: "errors/500_error", layout: false
        end
    end

    def show
        response = @conn.get "/students/"+@student_id
        if success(response)
            @student = JSON.parse response.body
            @courses=[]
            response2 = @conn_department.get "/departments/"+@student['departmentId'].to_s
            @department = JSON.parse response2.body
        else
            render template: "errors/404_error", layout: false
        end
    end

    def new
        response = @conn_department.get "/departments"
        @departments = JSON.parse response.body
        @departments_list = []
        @departments.each do |department|
            d = [department['name'], department['id']]
            @departments_list.push(d)
        end
        @selected_department = 1
        @student = {'departmentId' => "", 'name' => "", 'rollNumber' => ""}
        @errors = []
    end

    def create
        @student_obj = student_params
        response = @conn.post "/students", @student_obj.to_json
        if success(response)
            @student = JSON.parse response.body
            redirect_to student_path(@student)
        else
            @student = {'departmentId' => @student_obj[:student][:departmentId], 'name' => @student_obj[:student][:name], 'rollNumber' => @student_obj[:student][:rollNumber]}
            @errors = JSON.parse response.body
            @selected_department = @student['departmentId']
            response = @conn_department.get "/departments"
            @departments = JSON.parse response.body
            @departments_list = []
            @departments.each do |department|
                d = [department['name'], department['id']]
            @departments_list.push(d)
            end
            render :new
        end
    end

    def edit
        response = @conn.get "/students/"+@student_id.to_s+"/edit"
        if success(response)
            @student = JSON.parse response.body
            response2 = @conn_department.get "/departments"
            @departments = JSON.parse response2.body
            @departments_list = []
            @departments.each do |department|
                d = [department['name'], department['id']]
                @departments_list.push(d)
            end
            @selected_department = @student['departmentId']
            @errors = []
        else
            render template: "errors/404_error", layout: false
        end
    end

    def update 
        @student_obj = student_params
        response = @conn.put "/students/"+@student_id.to_s, @student_obj.to_json
        if success(response)
            @student = JSON.parse response.body
            redirect_to student_path(@student)
        else
            @student = {'departmentId' => @student_obj[:student][:departmentId], 'name' => @student_obj[:student][:name], 'rollNumber' => @student_obj[:student][:rollNumber]}
            @errors = JSON.parse response.body
            @selected_department = @student['departmentId']
            response = @conn_department.get "/departments"
            @departments = JSON.parse response.body
            @departments_list = []
            @departments.each do |department|
                d = [department['name'], department['id']]
            @departments_list.push(d)
            end
            render :edit
        end

    end

    def destroy
        response = @conn.delete "/students/"+@student_id.to_s
        if success(response)
            redirect_to students_path
        else
            render template: "errors/404_error", layout: false
        end
    end

    private

        def student_params
            {student: {departmentId: params[:departmentId], name: params[:name], rollNumber: params[:rollNumber]}}
        end

        def set_student_id
            @student_id  = params[:id]
        end

        def set_conn
            @conn = Faraday.new(
                url: 'http://localhost:3002',
                headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
            )do |c|
                c.use Circuitbox::FaradayMiddleware, identifier: 'student_microservice_circuit', circuit_breaker_options: {sleep_window: 60, time_window: 60, volume_threshold: 10, error_threshold: 50}
            end
        end

        def set_conn_with_department
            @conn_department = Faraday.new(
                url: 'http://localhost:3001',
                headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
            )do |c|
                c.use Circuitbox::FaradayMiddleware, identifier: 'department_microservice_circuit', circuit_breaker_options: {sleep_window: 60, time_window: 60, volume_threshold: 10, error_threshold: 50}
            end
        end

        def success response
            if response.status < 400
                return true
            else return false
            end
        end
end
