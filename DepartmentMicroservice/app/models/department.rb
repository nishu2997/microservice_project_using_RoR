class Department < ApplicationRecord
    validates :name, presence: true
    validates :departmentCode, uniqueness: {case_sensitive: false}, presence: true
end
