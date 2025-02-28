module Postgres
  module Views
    def self.destroy_all_course_views
      courses = ::Course.all

      courses.each do |course|
        destroy_course_schema(course.id)
      end
    end

    def self.destroy_course_schema(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
            DROP SCHEMA IF EXISTS course_#{course_id} CASCADE;
        SQL
      )
    end

    def self.create_all_course_views
      courses = ::Course.all

      courses.each do |course|
        create_course_views(course.id)
      end
    end

    def self.create_course_views(course_id)
      create_views_schema(course_id)
      Course.create(course_id)
      Question.create(course_id)
      Tag.create(course_id)
      Enrollment.create(course_id)
      QuestionState.create(course_id)
      User.create(course_id)
      ::Postgres::Views::Role.create(course_id)
      ::Postgres::Views::QuestionTag.create(course_id)
    end

    def self.create_views_schema(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        CREATE SCHEMA IF NOT EXISTS course_#{course_id}
      SQL
      )

      create_user(course_id)
      grant_privileges(course_id)
    end

    def self.create_user(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        do $$ begin
          if not exists (SELECT usename FROM pg_user WHERE usename = 'course_#{course_id}_user') then
            CREATE USER course_#{course_id}_user;
            ALTER USER course_#{course_id}_user PASSWORD '#{SecureRandom.urlsafe_base64(10)}';
          end if;
        end $$;
      SQL
      )
    end

    def self.destroy_user(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        do $$ begin
          if exists (SELECT usename FROM pg_user WHERE usename = 'course_#{course_id}_user') then
            REVOKE ALL ON SCHEMA course_#{course_id} FROM course_#{course_id}_user;
            REVOKE ALL ON ALL TABLES IN SCHEMA course_#{course_id} FROM course_#{course_id}_user;
          end if;
        end $$;
        DROP ROLE IF EXISTS course_#{course_id}_user;
      SQL
      )
    end

    def self.grant_privileges(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        GRANT ALL ON SCHEMA course_#{course_id} TO GROUP course_#{course_id}_user;
        GRANT SELECT ON ALL TABLES IN SCHEMA course_#{course_id} to course_#{course_id}_user
      SQL
      )
    end
  end
end
