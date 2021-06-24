class Course < ApplicationRecord
    validates :name, presence: true
    validates :courseCode, uniqueness: {case_sensitive: false}, presence: true
    validates :departmentId, presence: true
end
