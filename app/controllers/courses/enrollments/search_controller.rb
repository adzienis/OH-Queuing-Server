module Courses
  module Enrollments
    class SearchController < ApplicationController
      respond_to :html

      def current_ability
        @current_ability ||= Courses::EnrollmentAbility.new(current_user, {
          params: params,
          path_parameters: request.path_parameters
        })
      end

      def index
        authorize! :search, Enrollment

        builder = ::Search::ClauseBuilder.new(attributes: [:user_full_name, :role_name, :sections], params: params)

        where_params = builder.build_clauses(params)
        aggs = [:user_full_name, :role_name, :sections]
        order_params = builder.build_order_clauses(request.query_parameters)

        @enrollment_results = Enrollment.pagy_search(params[:q].present? ? params[:q] : "*",
                                                     aggs: aggs,
                                                     where: where_params.merge({discarded_at: nil, course_id: @course.id}),
                                                     order: order_params)
        @pagy, @results = pagy_searchkick(@enrollment_results, items: 10)
      end
    end

  end
end