# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class QuestionStates < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace :courses do
      route_param :course_id do
        resource :question_states do

          desc "Gets all active TA's for a course on a date."
          params do
            optional :date, type: String
          end
          get :ta_feed do
            time = Time.zone.now
            time = Time.zone.parse(params[:date]) if params[:date]

            states = QuestionState.all
            states = states.accessible_by(current_ability) if current_user
            states = states.with_course(Course.find(params[:course_id]))
            states = states
                       .where('question_states.created_at < ?', time.end_of_day)
                       .where('question_states.created_at > ?', time.beginning_of_day)
                       .where(state: ['resolved', 'frozen'])
                       .as_json include: :user
            states
          end
        end

      end

    end

    resource :question_states do

      desc "Create a question state."
      params do
        requires :question_state, type: Hash do
          requires :enrollment_id, type: Integer
          requires :state, type: String
          requires :question_id, type: Integer
          optional :description, type: String
        end
      end
      post do
        question_state = QuestionState.new(declared(params)[:question_state])

        authorize! :create, question_state

        question_state = QuestionState.create!(declared(params)[:question_state])
      end

    end
  end
end
