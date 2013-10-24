# Use RVM (ruby-version is on server)
require "rubygems"
require "bundler/capistrano"
# set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
require "delayed/recipes"

# set :rails_env, "production" #added for delayed job  

# Precompile Assets
load 'deploy/assets'

set :applicationdir, "/srv/www/diode/application"

set :application, "Diode"
set :scm, 'git'
set :repository,  "git@github.com:StanfordHCI/diode.git"
set :git_enable_submodules, 1 # if you have vendored rails
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
#Set forward agent because the server has multiple repositories cloned on it.
set :ssh_options, { :forward_agent => true }



desc "Run on ec2: Server in us-west-2b (Oregon)"
task :grader do
  set :rvm_ruby_string, 'ruby-1.9.3'
  require "rvm/capistrano"
  server "ubuntu@54.203.252.80", :web, :app, :db, :primary => true
end

desc "Run on ANOTHERSERVER"
task :clr3 do
  set :rvm_ruby_string, 'ruby-1.9.3'
  set :rvm_type, :system
  require "rvm/capistrano"
  server "root@ANOTHERSERVER", :web, :app, :db, :primary => true
end

set :deploy_to, applicationdir
set :deploy_via, :export

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa"), File.join(ENV["HOME"], ".ssh","ec2.pem")]

# Generate an additional task to fire up the thin clusters
namespace :deploy do
  desc "Start the Thin processes"
  task :start do
    run  <<-CMD
      cd /srv/www/diode/application/current; bundle exec thin start -C config/thin.yml 
    CMD
  end

  desc "Stop the Thin processes"
  task :stop do
    run <<-CMD
      cd /srv/www/diode/application/current; bundle exec thin stop -C config/thin.yml 
    CMD
  end

  desc "Restart the Thin processes"
  task :restart do
    run <<-CMD
      cd /srv/www/diode/application/current; bundle exec thin restart -C config/thin.yml
    CMD
  end
  # namespace :assets do
  #   desc "Precompile assets locally and then rsync to app servers"
  #   task :precompile, :only => { :primary => true } do
  #     run_locally "rake assets:precompile;"
  #     servers = find_servers :roles => [:app], :except => { :no_release => true }
  #     servers.each do |server|
  #       run_locally "rsync -av ./public/assets/ #{user}@#{server}:#{current_path}/public/assets/;"
  #     end
  #     run_locally "rm -rf public/assets"
  #   end
  # end

  # namespace :assets do
  #       task :precompile, :roles => :web, :except => { :no_release => true } do
  #         from = source.next_revision(current_revision)
  #         if releases.length <= 1 || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
  #           run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
  #         else
  #           logger.info "Skipping asset pre-compilation because there were no asset changes"
  #         end
  #     end
  # end
end



# Symlink database.yml on the server
namespace :deploy do
  desc "Symlinks the database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Symlinks the constants file"
  task :symlink_constants, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/initializers/constants.rb #{release_path}/config/initializers/constants.rb"
  end

  desc "Symlinks the log file"
  task :symlink_log, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/log/production.log #{release_path}/log/production.log"
  end

  # desc "Symlinks the paperclip uploads folder"
  # task :symlink_paperclip, :roles => :app do
  #   run "ln -nfs #{deploy_to}/shared/log/production.log #{release_path}/log/production.log"
  # end
end



# namespace :config do
#   task :nginx, roles: :app do
#     puts "Symlinking your nginx configuration..."
#     sudo "ln -nfs #{release_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
#   end
# end

# after "deploy:setup", "config:nginx"


# # Restart the delayed_job process
# namespace :delayed_job do 
#   desc "Restart the delayed_job process"
#   task :restart, :roles => :app do
#     run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
#   end
# end

# Define all the tasks that need to be running manually after Capistrano is finished.
before 'deploy:assets:symlink', 'deploy:symlink_constants'
before 'deploy:assets:symlink', 'deploy:symlink_log'
before 'deploy:assets:precompile', 'deploy:symlink_db'
before 'deploy:restart', 'deploy:migrate'
# before 'deploy:restart', 'delayed_job:restart' # deploy:update_code

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

# If you want to use command line options, for example to start multiple workers,
# define a Capistrano variable delayed_job_args:
#
#   set :delayed_job_args, "-n 2"
# require './config/boot'
# require 'airbrake/capistrano'
