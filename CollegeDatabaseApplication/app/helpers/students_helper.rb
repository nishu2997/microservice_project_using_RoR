module StudentsHelper
    BASE = "http://localhost:3000/students"
    def student_path student
        BASE+"/"+student['id'].to_s
    end

    def edit_student_path student
        BASE+"/"+student['id'].to_s+"/edit"
    end

    def students_path
        BASE
    end

    def new_student_path
        BASE+"/new"
    end
end
