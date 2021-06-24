class CreateStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.integer :departmentId, null: false
      t.string :name, null: false
      t.integer :rollNumber, null: false
      t.timestamps
    end
  end
end
