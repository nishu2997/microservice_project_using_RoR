module CoursesHelper
    BASE = "http://localhost:3000/courses"
    def course_path course
        BASE+"/"+course['id'].to_s
    end

    def edit_course_path course
        BASE+"/"+course['id'].to_s+"/edit"
    end

    def courses_path
        BASE
    end

    def new_course_path
        BASE+"/new"
    end
end
