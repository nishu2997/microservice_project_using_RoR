require 'faraday'
require 'circuitbox/faraday_middleware'
class CoursesController < ApplicationController
    include CoursesHelper
    before_action :set_course_id, only: [:show, :edit, :update, :destroy]
    before_action :set_conn
    before_action :set_conn_with_department

    def index
        begin
            response = @conn.get "/courses"
            @courses = JSON.parse response.body
        rescue => e
            render template: "errors/500_error", layout: false
        end
    end

    def show
        response = @conn.get "/courses/"+@course_id
        if success(response)
            @course = JSON.parse response.body
            response2 = @conn_department.get "/departments/"+@course['departmentId'].to_s
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
        @course = {'departmentId' => "", 'name' => "", 'courseCode' => ""}
        @errors = []
    end

    def create
        @course_obj = course_params
        response = @conn.post "/courses", @course_obj.to_json
        if success(response)
            @course = JSON.parse response.body
            redirect_to course_path(@course)
        else
            @course = {'departmentId' => @course_obj[:course][:departmentId], 'name' => @course_obj[:course][:name], 'courseCode' => @course_obj[:course][:courseCode]}
            @errors = JSON.parse response.body
            @selected_department = @course['departmentId']
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
        response = @conn.get "/courses/"+@course_id.to_s+"/edit"
        if success(response)
            @course = JSON.parse response.body
            response2 = @conn_department.get "/departments"
            @departments = JSON.parse response2.body
            @departments_list = []
            @departments.each do |department|
                d = [department['name'], department['id']]
                @departments_list.push(d)
            end
            @selected_department = @course['departmentId']
            @errors = []
        else
            render template: "errors/404_error", layout: false
        end
    end

    def update
        @course_obj = course_params
        response = @conn.put "/courses/"+@course_id.to_s, @course_obj.to_json
        if success(response)
            @course = JSON.parse response.body
            redirect_to course_path(@course)
        else
            @course = {'departmentId' => @course_obj[:course][:departmentId], 'name' => @course_obj[:course][:name], 'courseCode' => @course_obj[:course][:courseCode]}
            @errors = JSON.parse response.body
            @selected_department = @course['departmentId']
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
        response = @conn.delete "/courses/"+@course_id.to_s
        if success(response)
            redirect_to courses_path
        else
            render template: "errors/404_error", layout: false
        end
    end

    private

        def course_params
            {course: {departmentId: params[:departmentId], name: params[:name], courseCode: params[:courseCode]}}
        end

        def set_course_id
            @course_id  = params[:id]
        end

        def set_conn
            @conn = Faraday.new(
                url: 'http://localhost:3003',
                headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
            )do |c|
                c.use Circuitbox::FaradayMiddleware, identifier: 'course_microservice_circuit', circuit_breaker_options: {sleep_window: 60, time_window: 60, volume_threshold: 10, error_threshold: 50}
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
