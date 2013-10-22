Question, max_score, min score ->  Attributes -> Correct, Incorrect, score
answer: response, predicted_score, evaluations_wanted, total_evaluations, current_score
Evaluation: question_id, answer_id, reason, student_id, verified_true_count, verified_false_count


Grading: need to get next thing to be graded by user, if enough in same step, go to next step
evaluations: make sure evaluation is legit, update all the answers columns (required evaluations) etc
Grading: edit grades?

Do one grading at a time. If multiple boxes are selected, then create multiple evaluation objects, one for each attribute. 

Push them all into the verification pool (i.e. save the evaluation object). Once in the verification pool, wait till verified_true count is 2. If verified_false reaches 2, then push it back into the grading pool.

Store all verifications

There are two pools. Grading and verification. Answers in the grading pool either have no peer assessment, or have an inconclusive assessment. Those in the verification pool have an initial peer guess about their correctness. Answers move between the grading and the verification pool, depending on peer grading. Once they have been successfully verified, they are then marked "verified" and removed from both pools. 

Once an answer is marked as "verified", these things happen: 
1. Its score field is set as the sum of verified attributes, bound by the question's [min_score, max_score]
2. Its state is marked as verified

Each answer has an assessment created on identify. Assessments have many evaluations, one for each checked attribute

TODO:

Devise setup
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { :host => 'localhost:3000' }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root :to => "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. If you are deploying on Heroku with Rails 3.2 only, you may want to set:

       config.assets.initialize_on_precompile = false

     On config/application.rb forcing your application to not access the DB
     or load models when precompiling your assets.

  5. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================
