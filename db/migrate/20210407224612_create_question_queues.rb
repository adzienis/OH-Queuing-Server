class CreateQuestionQueues < ActiveRecord::Migration[6.1]
  def change
    create_table :question_queues do |t|
      t.belongs_to :course
      t.timestamps
    end
  end
end
