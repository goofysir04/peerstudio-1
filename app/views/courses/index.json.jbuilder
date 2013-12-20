json.array!(@courses) do |course|
  json.extract! course, :id, :name, :image_url, :institution, :hidden, :open_enrollment, :user_id
  json.url course_url(course, format: :json)
end
