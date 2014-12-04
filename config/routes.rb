Humanmachine::Application.routes.draw do
  Rails.application.routes.default_url_options[:protocol]="https"
  get "welcome/index"
  get "welcome/contact"
  get "welcome/tos"
  get "uploads/create"
  get "uploads/authenticate_asset" => "uploads#authenticate_asset"

  resources :courses do
    resources :assignments, shallow: true
    collection do
      get 'help'
      get 'about'
    end
    member do
      post 'regenerate_consumer_secret'
      post 'enroll_lti'
      post 'make_instructor'
      get 'instructor_list'
    end
  end

  resources :assignments do
    resources :answers, shallow: true
    member do
      get 'stats'
      get 'grades'
      get 'export_grades'
      post 'update_grade/:grade_id' => "assignments#update_grade", as: :update_grade
      post 'resolve' => 'assignments#resolve_action_item', as: :resolve_action_item
      get "show_all_answers"
      get 'review_first'
      post 'create_typed_review' => 'reviews#create_with_type'
      get 'waitlist'
      get 'flipbook'
      post 'regrade'
    end
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
      post 'direct_upload_attachment'
      delete 'delete_attachment'
      get 'star' => 'answers#star'
      get 'submit_for_feedback' => 'answers#feedback_preferences'
      post 'submit_for_feedback'
      post 'unsubmit_for_feedback'
      post 'submit_for_grades'
      post 'unsubmit_for_grades'
      get 'reflect'
      post 'clone'
      post 'upgrade'
    end
    resources :reviews, shallow: true
  end


  get 'reviews/:id/rate' => "reviews#rate", as: :rate_review
  post 'reviews/:id/rate' => "reviews#create_rating", as: :create_rate_review
  post 'reviews/:id/blank' => "reviews#report_blank", as: :report_blank_answer
  post 'reviews/:answer_id/review_answer' => "reviews#review_answer", as: :review_answer

  resources :questions do
    #resources :answer_attributes
  end

  resources :rubric_items do
    resources :answer_attributes, shallow: true
  end

  #root 'grading#index'
  # root 'courses#index'
  authenticated do
    root :to => 'courses#index', as: :authenticated
  end
  root :to => 'welcome#index'
  # get 'welcome' => 'welcome#index'

  #Connect controller

  post "connect/assignments/:id" => "lti#enroll_in_assignment", as: :lti_enrollment
  get "connect/complete/:id" => "lti#complete_enrollment", as: :complete_lti_enrollment
  get "connect/test" => "lti#test"
  get "connect/guide/:id" => "lti#guide"

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
