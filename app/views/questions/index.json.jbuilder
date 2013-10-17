json.array!(@questions) do |question|
  json.extract! question, :title, :explanation
  json.url question_url(question, format: :json)
end
