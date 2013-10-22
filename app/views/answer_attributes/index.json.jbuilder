json.array!(@attributes) do |attribute|
  json.extract! attribute, :is_correct, :score, :question_id, :created_at, :updated_at, :description
  json.url attribute_url(attribute, format: :json)
end
