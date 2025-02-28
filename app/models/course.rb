# == Schema Information
#
# Table name: courses
#
#  id              :bigint           not null, primary key
#  name            :string
#  course_code     :string
#  student_code    :string
#  ta_code         :string
#  instructor_code :string
#  open            :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Course < ApplicationRecord
  include Turbo::Broadcastable
  include HasEnrollables
  include HasMetabaseEntities
  extend Pagy::Searchkick
  searchkick

  validates :name, presence: true, uniqueness: { scope: :semester }
  validates :ta_code, presence: true, uniqueness: true, on: :create
  validates :student_code, presence: true, uniqueness: true, on: :create
  validates :instructor_code, presence: true, uniqueness: true, on: :create

  # Not required for now
  # validates :course_code, presence: true, uniqueness: true

  has_many :enrollments_import_records, :class_name => 'Courses::Enrollments::ImportRecord'
  has_one :certificate
  has_many :tag_groups, dependent: :destroy
  has_many :settings, as: :resource, dependent: :destroy
  has_many :questions, through: :enrollments
  has_many :analytics_dashboards, class_name: "Analytics::Dashboard"
  has_many :unresolved_questions, -> { undiscarded.by_state("unresolved") }, class_name: "Question"
  has_many :active_questions, -> {
                                Question.undiscarded.by_state("unresolved", "frozen", "resolving")
                              }, through: :enrollments, class_name: "Question", source: :questions

  has_many :questions_on_queue, -> { by_state("unresolved", "frozen").undiscarded },
    through: :enrollments,
    source: :questions,
    class_name: "Question"
  has_many :all_questions_on_queue, -> { by_state("unresolved", "frozen", "resolving").undiscarded },
    through: :enrollments,
    source: :questions,
    class_name: "Question"
  has_many :tags, dependent: :destroy
  has_many :queue_status_logs, dependent: :destroy
  # has_many :announcements

  has_many :courses_sections, class_name: "Courses::Section", dependent: :destroy

  has_one :ta_role, -> { where(name: "ta") },
    as: :resource,
    class_name: "Role",
    inverse_of: :course
  has_one :instructor_role, -> { where(name: "instructor") },
    as: :resource,
    class_name: "Role",
    inverse_of: :course
  has_one :lead_ta_role, -> { where(name: "lead_ta") },
    as: :resource,
    class_name: "Role",
    inverse_of: :course
  has_one :student_role, -> { where(name: "student") },
    as: :resource,
    class_name: "Role",
    inverse_of: :course

  before_validation on: :create do
    self.ta_code = SecureRandom.urlsafe_base64(6) unless ta_code.present?
    self.student_code = SecureRandom.urlsafe_base64(6) unless student_code.present?
    self.instructor_code = SecureRandom.urlsafe_base64(6) unless instructor_code.present?
  end

  scope :with_user, ->(user_id) {
    joins(:enrollments).merge(Enrollment.active.with_user(user_id))
  }

  scope :with_setting, ->(key, value) { joins(:settings).merge(Setting.with_key(key).with_value(value)) }

  def search_data
    {
      id: id,
      name: name,
      created_at: created_at,
      updated_at: updated_at

    }
  end

  def self.find_by_code?(code)
    find_by_code(code).present?
  end

  def connected_staff
    staff.joins(:user).merge(User.online)
  end

  def self.find_by_code(code)
    ta_course = Course.find_by(ta_code: code)
    instructor_course = Course.find_by(instructor_code: code)

    return ta_course, :ta if ta_course
    return instructor_course, :instructor if instructor_course

    nil
  end

  def setting(key)
    settings.find_by_key(key)
  end

  # Course Roles Finders
  # #####################################################3

  def self.find_staff_roles(user = nil)
    Role.joins(enrollments: :user).where("users.id": user)
      .where("roles.resource_type": "Course", name: [:ta, :lead_ta, :instructor])
      .merge(Enrollment.active)
  end

  def self.find_unprivileged_roles(user = nil)
    Role.joins(enrollments: :user).where("users.id": user)
      .where("roles.resource_type": "Course", name: [:student])
      .merge(Enrollment.active)
  end

  def self.find_privileged_staff_roles(user = nil)
    Role.joins(enrollments: :user).where("users.id": user)
      .where("roles.resource_type": "Course", name: [:lead_ta, :instructor])
      .merge(Enrollment.active)
  end

  def answerable_questions(tag_names: nil)
    if tag_names.present?
      active_questions
        .left_joins(:tags)
        .where("tags.name": tag_names)
        .group("questions.id")
        .having("count(*) = #{tag_names.count}")
        .filter { |q| q.unresolved? }
    else
      active_questions
        .includes(:question_state)
        .left_joins(:tags)
        .filter { |q| q.unresolved? }
    end
  end

  def answerable_questions?(tag_names: nil)
    answerable_questions(tag_names: tag_names).any?
  end

  def student_role
    roles.find_by("roles.name": "student")
  end

  def instructor_role
    roles.find_by("roles.name": "instructor")
  end

  def ta_role
    roles.find_by("roles.name": "ta")
  end

  def lead_ta_role
    roles.find_by("roles.name": "lead_ta")
  end

  def available_tags
    tags.undiscarded.unarchived.distinct
  end

  def public_columns
    select(Course.column_names - ["instructor_code", "ta_code"])
  end

  after_create do
    Postgres::Views.create_course_views(id)
  end

  after_create_commit do
    Analytics::Metabase::SyncDatabaseJob.perform_later
    Analytics::Metabase::SetupJob.set(wait: 1.minute).perform_later(course: self)

    settings.create([{
      bag: {
        label: "Searchable",
        key: "searchable",
        value: "false",
        description: "Allow students to search for this course.",
        type: "boolean",
        category: "General"
      }
    }, {
      bag: {
        label: "Allow Enrollment",
        key: "allow_enrollment",
        value: "false",
        description: "Allow users to enroll in the course.",
        type: "boolean",
        category: "Enrollment"
      }
    }])

    roles.create([{name: "instructor"}, {name: "ta"}, {name: "student"}, {name: "lead_ta"}])
  end

  after_destroy_commit do
    Postgres::Views::Course.destroy(id)
    Postgres::Views::Question.destroy(id)
    Postgres::Views::Tag.destroy(id)
    Postgres::Views::Enrollment.destroy(id)
    Postgres::Views.destroy_user(id)
    Postgres::Views.destroy_course_schema(id)
  end
end
