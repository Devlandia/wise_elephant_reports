set :application,               "Sinatra Saploe APP"
set :repository,                "git@github.com:rodrigovdb/default-sinatra-app"
set :scm,                        "git"
set :user,                       "ubuntu"
set :use_sudo,                   false
set :deploy_to,                  "/home/ubuntu/sinatra/"
set :normalize_asset_timestamps, false

role :web, "ladodireito.com"                          # Your HTTP server, Apache/etc
role :app, "ladodireito.com"                          # This may be the same as your `Web` server

set :bundle_cmd, "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247@global/bin/bundle"
set :bundle_dir, "/home/ubuntu/.rvm/gems/ruby-2.0.0-p247"

after :deploy do
  remote.bundle_install
end

namespace :remote do
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
end
