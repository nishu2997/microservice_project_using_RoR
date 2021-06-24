class Student < ApplicationRecord
    validates :name, presence: true
    validates :rollNumber, uniqueness: true, presence: true
    validates :departmentId, presence: true
end
