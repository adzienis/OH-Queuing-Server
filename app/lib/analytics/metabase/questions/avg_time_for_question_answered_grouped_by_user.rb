class Analytics::Metabase::Questions::AvgTimeForQuestionAnsweredGroupedByUser
  def initialize(database_id:, course_schema:, collection_id:, date_field_id:, full_name_field_id:)
    @database_id = database_id
    @course_schema = course_schema
    @collection_id = collection_id
    @date_field_id = date_field_id
    @full_name_field_id = full_name_field_id
  end

  def call
    {
      name: "Avg Time to Answer Grouped By User (Date Filter)",
      dataset_query: {
        type: "native",
        native: {
          "template-tags": {
            full_name: {
              id: "6bec6e64-0613-8af0-bb02-a9c82a6a52a9",
              name: "full_name",
              "display-name": "Full name",
              type: "dimension",
              required: false,
              dimension: ["field", full_name_field_id, nil],
              "widget-type": "category"
            },
            date: {
              id: "4cb40565-939e-341b-4ab2-be4083402faa",
              name: "date",
              "display-name": "Date",
              type: "dimension",
              dimension: ["field", date_field_id, nil],
              "widget-type": "date/all-options",
              required: true,
              default: "thisday"
            }
          },
          query: query
        },
        database: database_id
      },
      display: "bar",
      description: nil,
      visualization_settings: {
        "table.pivot_column": "user_id",
        "table.cell_column": "questions_count",
        "graph.dimensions": ["full_name"],
        "graph.show_goal": true,
        "graph.goal_value": 600,
        "graph.goal_label": "10 Min",
        "graph.metrics": ["total_time", "questions_count"]
      }, archived: false,
      enable_embedding: false,
      embedding_params: nil,
      collection_id: collection_id,
      collection_position: nil
    }
  end

  private

  attr_accessor :database_id, :course_schema, :filters, :collection_id, :date_field_id, :full_name_field_id

  def query
    <<~SQL
      SELECT #{course_schema}.users.id user_id, 
      #{course_schema}.users.given_name || ' ' || #{course_schema}.users.family_name full_name, 
      COUNT(*) questions_count,
      extract(epoch from avg(subquery.created_at - subquery_min.created_at)) total_time FROM #{course_schema}.questions
      INNER JOIN #{course_schema}.enrollments ON #{course_schema}.enrollments.id = #{course_schema}.questions.enrollment_id
      INNER JOIN #{course_schema}.users ON #{course_schema}.users.id = #{course_schema}.enrollments.user_id
      JOIN LATERAL ((SELECT #{course_schema}.question_states.created_at FROM #{course_schema}.question_states WHERE
      (id IN (SELECT max(id) FROM #{course_schema}.question_states 
      WHERE (question_id = #{course_schema}.questions.id and state = 2)))))
      subquery ON true JOIN LATERAL ((SELECT #{course_schema}.question_states.created_at 
      FROM #{course_schema}.question_states
      WHERE (id in (SELECT max(id) FROM #{course_schema}.question_states
      WHERE (question_id = #{course_schema}.questions.id and state = 1))))) subquery_min ON true
      WHERE {{full_name}} AND {{date}} 
      GROUP BY #{course_schema}.users.id, #{course_schema}.users.given_name, #{course_schema}.users.family_name 
      ORDER BY questions_count DESC LIMIT 10
    SQL
  end
end
