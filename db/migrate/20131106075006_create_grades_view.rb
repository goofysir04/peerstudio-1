#This view file is commented out, because some sqlite3 doesn't allow views, and we materialized views later

# class CreateGradesView < ActiveRecord::Migration
#   def up
#   	create_view :answer_grades, %q(SELECT answer_id,
#              sum(answer_score) AS final_score,
#              avg(answer_score) AS avg_final_score
#       FROM
#         (SELECT answer_attributes.score AS answer_score,
#                 verified_answers.answer_id
#          FROM answer_attributes,
#            (SELECT answer_id,
#                    answer_attribute_id,
#                    id,
#                    assessment_id
#             FROM evaluations
#             WHERE verified_true_count >verified_false_count
#               AND verified_true_count > 0) AS verified_answers
#          WHERE verified_answers.answer_attribute_id = answer_attributes.id) AS answer_scores,
#            answers
#       WHERE answer_scores.answer_id = answers.id
#       GROUP BY answer_scores.answer_id)
#   end

#   def down
#   	drop_view :answer_grades
#   end
# end
