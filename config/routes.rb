Humanmachine::Application.routes.draw do

  resources :courses do
    resources :assignments, shallow: true
  end

  resources :assignments do
    resources :answers, shallow: true
  end


  # mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "registrations" }

  devise_scope :user do 
    get 'users/start' => 'registrations#start_openid', :as => :start_openid_registration
    post 'users/complete' => 'registrations#complete_openid', :as => :complete_openid_registration
    get 'users/impersonate' => 'registrations#impersonate', :as=>:impersonate_user
    post 'users/upload' => 'registrations#upload', as: :upload_users
    get 'users/import' => 'registrations#import'
  end

  get "grading/identify/:id" => "grading#identify", as: :grade_identification
  post "grading/identify" => 'grading#create_assessment', as: :create_grade_identification
  get "grading/undo_identify/:id" => "grading#undo_assessment", as: :undo_grade_identification
  
  get "grading/verify/:id" => "grading#verify", as: :grade_verification
  post "grading/verify" => "grading#create_verification", as: :create_grade_verification
  
  get "grading/evaluate/:id" => "grading#baseline_evaluate", as: :grade_baseline
  post "grading/evaluate" => 'grading#create_baseline_assessment', as: :create_grade_baseline

  get "grading/my_grades" => "grading#my_grades", as: :my_grades
  get "grading/push_grades" => "grading#push_grades", as: :push_grades

  get "grading/appeal/:id" => "grading#appeal", as: :appeal_grading
  post "grading/appeal/:id" => "grading#create_appeal", as: :create_appeal_grading

  get "grading/staff_grade/:id" => "grading#staff_grade", as: :staff_grade
  post "grading/staff_grade" => "grading#create_staff_grade", as: :create_staff_grade

  get "grading/critique/:id" => "grading#early_feedback", as: :early_feedback
  resources :questions

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  resources :answers do
    collection do 
      get 'import'
      post 'upload'
    end
    member do 
      post 'upload_attachment'
      get 'star' => 'answers#star'
    end
    resources :reviews, shallow: true
  end

  resources :questions do
    #resources :answer_attributes
  end

  resources :rubric_items do 
    resources :answer_attributes, shallow: true
  end

  #root 'grading#index'
  root 'courses#index'

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
