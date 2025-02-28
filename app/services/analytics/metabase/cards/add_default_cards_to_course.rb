module Analytics
  module Metabase
    module Cards
      class AddDefaultCardsToCourse
        include Metabaseable

        def initialize(course:)
          @course = course
        end

        def call
          Analytics::Metabase::Dashboards::Create.new(name: "Main", collection_id: course.base_collection.id).call

          card = Analytics::Metabase::Questions::
              AvgTimeForQuestionAnsweredGroupedByUser.new(database_id: db.id,
                course_schema: course.custom_schema,
                collection_id: course.base_collection.id,
                date_field_id: fields(table_name: "Questions")["Created At"]["id"],
                full_name_field_id: fields(table_name: "Users")["Given Name"]["id"]).call
          create_card(card)

          card = Analytics::Metabase::Questions::AvgTimePerTag.new(database_id: db.id,
            course_schema: course.custom_schema,
            collection_id: course.base_collection.id).call
          create_card(card)

          card = Analytics::Metabase::Questions::GroupedByDate.new(course: course,
            collection_id: course.base_collection.id).call

          create_card(card)

          card = Analytics::Metabase::Questions::CreatedThisWeekCount.new(course: course,
            collection_id: course.base_collection.id).call

          create_card(card)

          card = Analytics::Metabase::Questions::CreatedCurrentMonthCount.new(course: course,
            collection_id: course.base_collection.id,
            default_semester: Enrollment.default_semester).call

          create_card(card)

          card = Analytics::Metabase::Questions::CreatedCurrentDayCount.new(course: course,
                                                                              collection_id: course.base_collection.id,
                                                                              default_semester: Enrollment.default_semester).call

          create_card(card)

          card = Analytics::Metabase::Questions::CreatedCurrentSemesterCount.new(course: course,
                                                                              collection_id: course.base_collection.id,
                                                                              default_semester: Enrollment.default_semester).call

          create_card(card)

          card = Analytics::Metabase::Questions::AvgTimeForQuestionAnsweredByDay.new(course: course,
                                                                                 collection_id: course.base_collection.id,
                                                                                 default_semester: Enrollment.default_semester).call

          create_card(card)

          all_cards = course.base_collection.cards

          all_cards.each do |card|
            Analytics::Metabase::Dashboards::AddCardToDashboard.new(dashboard_id: course.mb_dashboards.first.id,
              card_id: card.id).call
          end
        end

        private

        attr_reader :course

        def fields(table_name: nil)
          fields = metabase.database_fields(db.id)
          fields = fields.filter { |v| v["table_name"] == table_name } if table_name.present?
          fields = fields.filter { |v| v["schema"] == course.custom_schema }

          fields.map { |v| [v["name"], v.except("name")] }.to_h
        end

        def create_card(card_json)
          Analytics::Metabase::Cards::Create.new(json: card_json).call
        end
      end
    end
  end
end
