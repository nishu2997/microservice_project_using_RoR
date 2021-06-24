module EnrollsHelper
    BASE = "http://localhost:3000/enrolls"
    def enroll_path enroll
        BASE+"/"+enroll['id'].to_s
    end

    def edit_enroll_path enroll
        BASE+"/"+enroll['id'].to_s+"/edit"
    end

    def enrolls_path
        BASE
    end

    def new_enroll_path
        BASE+"/new"
    end
end
