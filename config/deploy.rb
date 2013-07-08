set :application,               "Sinatra Saploe APP"
set :repository,                "git@github.com:rodrigovdb/default-sinatra-app"
set :scm,                        "git"
set :user,                       "ubuntu"
set :use_sudo,                   false
set :deploy_to,                  "/home/ubuntu/sinatra/"
set :normalize_asset_timestamps, false

role :web, "ladodireito.com"                          # Your HTTP server, Apache/etc
role :app, "ladodireito.com"                          # This may be the same as your `Web` server

set :unicorn_binary, "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247/bin/unicorn"
set :unicorn_config, "#{current_path}/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"
#set :unicorn_binary, "#{current_path}/bin/unicorn.sh"

before :deploy do
#  directory_name = "#{deploy_to}shared/pids"
#  Dir.mkdir(directory_name) unless File.exists?(directory_name)

#  directory_name = "#{deploy_to}/shared/sockets"
#  Dir.mkdir(directory_name) unless File.exists?(directory_name)
end

after :deploy do
  run "cd #{current_path} && ln -s #{deploy_to}/shared/sockets tmp/sockets"
  #remote.restart_unicorn
end

namespace :unicorn do
  ### RVM Definitions
  set :default_environment, {
    'PATH'          => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247/bin:/home/ubuntu/.rvm/gems/ruby-2.0.0-p247@global/bin:/home/ubuntu/.rvm/rubies/ruby-2.0.0-p247/bin:/home/ubuntu/.rvm/bin:$PATH",
    'RUBY_VERSION'  => 'ruby 2.0.0',
    'GEM_HOME'      => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247",
    'GEM_PATH'      => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247:/home/ubuntu/.rvm/gems/ruby-2.0.0-p247@global",
    'BUNDLE_PATH'   => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5",
  }

  desc "Start unicorn service"
  task :start, :roles => :app, :except => { :no_release => true } do
    #run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E production -D"
  end

  desc "Stop unicorn service"
  task :stop, :roles => :app, :except => { :no_release => true } do
    #run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end

  desc "Stop unicorn service with QUIT signal"
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    #run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end

  desc "Stop service and start"
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end

namespace :remote do
=begin
  ### RVM Definitions
  set :default_environment, {
    'PATH'          => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247/bin:/home/ubuntu/.rvm/gems/ruby-2.0.0-p247@global/bin:/home/ubuntu/.rvm/rubies/ruby-2.0.0-p247/bin:/home/ubuntu/.rvm/bin:$PATH",
    'RUBY_VERSION'  => 'ruby 2.0.0',
    'GEM_HOME'      => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247",
    'GEM_PATH'      => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247:/home/ubuntu/.rvm/gems/ruby-2.0.0-p247@global",
    'BUNDLE_PATH'   => "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5",
  }

  desc "Run bundle install @ current release"
  task :bundle_install do
    run "cd #{current_path} && #{bundle_cmd} install"
  end
=end
end
