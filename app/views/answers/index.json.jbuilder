json.array!(@answers) do |answer|
  json.extract! answer, :response, :question_id, :user_id, :predicted_score, :current_score, :evaluations_wanted, :total_evaluations, :confidence
  json.url answer_url(answer, format: :json)
end
