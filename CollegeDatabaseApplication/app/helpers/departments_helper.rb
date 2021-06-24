module DepartmentsHelper
    BASE = "http://localhost:3000/departments"
    def department_path department
        BASE+"/"+department['id'].to_s
    end

    def edit_department_path department
        BASE+"/"+department['id'].to_s+"/edit"
    end

    def departments_path
        BASE
    end

    def new_department_path
        BASE+"/new"
    end
end
