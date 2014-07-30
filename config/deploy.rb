require 'capistrano/rails'

set :application, 'peerstudio'
set :repo_url, 'git@github.com:StanfordHCI/peerstudio.git'

# set :rvm_ruby_version, '2.1.2'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :migration_role, :db
set :conditionally_migrate, :false
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }


set :default_env, { path: "/home/deploy/.rvm/gems/ruby-2.1.2/bin:/home/deploy/.rvm/gems/ruby-2.1.2@global/bin:/home/deploy/.rvm/rubies/ruby-2.1.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/deploy/.rvm/bin:$PATH" }
# set :keep_releases, 5
SSHKit.config.command_map[:rake]  = "bundle exec rake" #8
SSHKit.config.command_map[:rails] = "bundle exec rails"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      within release_path do
        with rails_env: fetch(:rails_env) do
            execute :rake, "db:migrate"
        end
        execute :touch, release_path.join('tmp/restart.txt')
        execute :bundle, "exec thin restart -O -C config/thin.yml"
        with rails_env: fetch(:rails_env) do
            execute :bundle, "exec bin/delayed_job restart"
        end
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'

  # before :starting, :set_rvm do 
  #   run "source /home/deploy/.rvm/scripts/rvm"
  # end

  task :set_rvm do 
    on roles(:all) do
      execute "source /home/deploy/.rvm/scripts/rvm"
    end
  end

  # namespace :db do 
  #   desc "Make symlink for database yaml"
  #   task :symlink do
  #     run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  #   end
  # end

  # after :finishing, 'deploy:update_code', "db:symlink"

  before :starting, :set_rvm
  after :updating, :migrate
end
