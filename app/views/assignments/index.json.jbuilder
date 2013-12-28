json.array!(@assignments) do |assignment|
  json.extract! assignment, :id, :title, :description, :due_at, :open_at, :user_id, :course_id
  json.url assignment_url(assignment, format: :json)
end
