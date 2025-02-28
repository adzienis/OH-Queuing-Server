module Shared
  module SearchFormHelper
    class SearchFormPresenter
      include Rails.application.routes.url_helpers
      include ActionView::Helpers::UrlHelper

      def initialize(current_user, records, model, options, params)
        @course = Course.find_by(id: params[:course_id])
        @model = model
        @records = records
        @options = options
        @current_user = current_user
      end

      def info_link(result)
        if @course && @records.count > 0
          polymorphic_path([@course, result])
        else
          polymorphic_path([@current_user, result])
        end
      end

      def can_import?
        if @course && @records.count > 0
          @options[:actions].include?(:import) &&
            @current_user.privileged_staff_of?(@course)
        else
          false
        end
      end

      def can_download?
        @options[:actions].include?(:download) && @records.count > 0
      end

      def can_create?
        if @model == Course
          @options[:actions].include?(:new) && Ability.new(@current_user, {}).can?(:create, Course)
        else
          @options[:actions].include?(:new) && @current_user.privileged_staff_of?(@course)
        end
      end
    end

    def filter_dropdown(options, model)
      associations = gen_associations(options, model)

      tag.div id: "dropdown-filter", data: {
        base: request.path,
        except: options[:except],
        columns: {
          root: model.columns.map { |v|
                  {v.name => {
                    type: v.type,
                    label: v.name.humanize
                  }}
                }.inject(:merge),
          associations: associations
        }, queries: params[:q],
        reset: request.path
      }.to_json do
      end
    end

    private

    def gen_associations(options, model)
      other_filters = options[:other_filters]

      other_filters.empty? ? [] :
        other_filters.keys.map { |e|
          {e => other_filters[e].map { |ee|
                  {ee.to_s => {
                    type: get_associations(model).map { |v| {v.name => v.klass} }.inject(:merge)[e].columns_hash[ee].type,
                    label: ee.to_s.humanize.to_s,
                    ass: e
                  }}
                }}
        }
    end
  end
end
