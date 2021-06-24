require 'faraday'
require 'circuitbox/faraday_middleware'
class DepartmentsController < ApplicationController
    class MyFaradayMiddleware < Faraday::Middleware
        def on_request(env)
            puts "request coming......."
            stored_value = Rails.cache.fetch('department_microservice_circuit') {{requests: 0, successful: 0, start: Time.now.to_i, open: 0}}
            if stored_value[:open]==0
                puts "request proceed...."
                if (Time.now.to_i - stored_value[:start]) >= 60   
                    stored_value[:start] = Time.now.to_i
                    stored_value[:requests]=0
                    stored_value[:successful]=0
                end
            elsif stored_value[:open] == 1 and (Time.now.to_i - stored_value[:start]) >= 60
                puts "request proceed...."
                stored_value[:open]=0
                stored_value[:start] = Time.now.to_i
                stored_value[:requests]=0
                stored_value[:successful]=0
            else
                puts "request skip....."
                raise Faraday::TimeoutError
            end
            stored_value[:requests]=stored_value[:requests]+1
            Rails.cache.write 'department_microservice_circuit', stored_value
        end

        def on_complete(env)
            puts "request completed......."
            response = Faraday::Response.new(env)
            stored_value = Rails.cache.read 'department_microservice_circuit'
            if !open? response
                stored_value[:successful] = stored_value[:successful]+1
            end
            puts stored_value
            if reached_threshold? stored_value
                puts "threshold reached, circuit is open........"
                stored_value[:open]=1
                stored_value[:start]=Time.now.to_i
            end
            Rails.cache.write 'department_microservice_circuit', stored_value
        end
        private
            def open? response
                response.status >= 500
            end

            def reached_threshold? stored_value
                unsuccessful = stored_value[:requests] - stored_value[:successful]
                stored_value[:requests]==2 and unsuccessful==stored_value[:requests]
            end
    end
    include DepartmentsHelper
    before_action :set_department_id, only: [:show, :edit, :update, :destroy]
    before_action :set_conn

    def index
        begin
            response = @conn.get "/departments"
            @departments = JSON.parse response.body
        rescue => e
            render template: "errors/500_error", layout: false
        end
    end

    def show
        response = @conn.get "/departments/"+@department_id
        if success(response)
            @department = JSON.parse response.body
        else
            render template: "errors/404_error", layout: false
        end
    end

    def new
        @department = {'name' => "", 'departmentCode' => ""}
        @errors = []
    end

    def create
        @department_obj = department_params
        response = @conn.post "/departments", @department_obj.to_json
        if success(response)
            @department = JSON.parse response.body
            redirect_to department_path(@department)
        else
            @department = {'name' => @department_obj[:department][:name], 'departmentCode' => @department_obj[:department][:departmentCode]}
            @errors = JSON.parse response.body
            render :new
        end
    end

    def edit
        response = @conn.get "/departments/"+@department_id.to_s+"/edit"
        if success(response)
            @department = JSON.parse response.body
            @errors = []
        else
            render template: "errors/404_error", layout: false
        end
    end

    def update
        @department_obj = department_params
        response = @conn.put "/departments/"+@department_id.to_s, @department_obj.to_json
        if success(response)
            #puts response.headers, response.status, response.body
            @department = JSON.parse response.body
            redirect_to department_path(@department)
        else
            @department = {'name' => @department_obj[:department][:name], 'departmentCode' => @department_obj[:department][:departmentCode]}
            @errors = JSON.parse response.body
            render :edit
        end

    end

    def destroy
        response = @conn.delete "/departments/"+@department_id.to_s
        if success(response)
            redirect_to departments_path
        else
            render template: "errors/404_error", layout: false
        end
    end

    private

        def department_params
            puts session[:_csrf_token]
            {authenticity_token: form_authenticity_token, department: {name: params[:name], departmentCode: params[:departmentCode]}}
        end

        def set_department_id
            @department_id  = params[:id]
        end

        def set_conn
            @conn = Faraday.new(
                url: 'http://localhost:3001',
                headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
            ) do |c|
                #c.use MyFaradayMiddleware
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
