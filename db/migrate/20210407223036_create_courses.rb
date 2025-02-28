# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :course_code
      t.string :student_code
      t.string :ta_code
      t.string :instructor_code
      t.boolean :open, default: false
      t.timestamps
    end
  end
end
