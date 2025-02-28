module Postgres
  module Views
    module Question
      def self.create(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.questions AS
          #{::Question.with_courses(course_id).to_sql}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.questions
        SQL
        )
      end
    end
  end
end
