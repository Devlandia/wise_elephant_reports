set stages,         %w{ development production }
set default_stage,  'development'

require 'mina/multistage'     # https://github.com/endoze/mina-multistage
require 'mina/bundler'
require 'mina/git'
require 'mina/rvm'
require 'mina/unicorn'        # https://github.com/scarfacedeb/mina-unicorn
require 'mina/nginx'          # https://github.com/hbin/mina-nginx
require 'mina/whenever'

# About unicorn integration:
# It's necessary config tmp/sockets and tmp/pids on shared_paths and
# create_deploy_dirs.
set :unicorn_env,   'production'
set :application,   'reports'
set :deploy_to,     "/var/www/#{application}"
set :repository,    'git@github.com:Devlandia/wise_elephant_reports.git'
set :forward_agent, true
set :port,          '22'
set :shared_paths,  %w{ log tmp/sockets tmp/pids config/database.yml config/settings.yml }

# My settings from mina extensions
set :ruby_version,    '2.2.0'
set :unicorn_config,  'config/unicorn.rb'

task :environment do
  invoke :"rvm:use[#{ruby_version}@default]"
end

# This doesn't invoke rvm things. It's necessary to start process
# when server doesn't have rvm already installed.
task :setup_environment do
end

task setup: :setup_environment do
  invoke :'create_deploy_dirs'
  invoke :'install_dependencies'
  invoke :'install_rvm'
  invoke :'configure_nginx'
end

desc "Deploys the current version to the server."
task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :'unicorn:restart'
    end

    invoke :'nginx:restart'
    invoke :'whenever:update' if stage == 'production'
  end
end

############################
#     Auxiliar methods     #
############################

# Create all required dirs on deploy dir
task create_deploy_dirs: :setup_environment do
  dirs  = %w{log config tmp/sockets tmp/pids}

  dirs.each do |dir|
    path  = "#{deploy_to}/#{shared_path}/#{dir}"
    queue! %[mkdir -p #{path}]
    queue! %[chmod g+rx,u+rwx #{path}]
  end
end

# Install OS dependencies. Initially thinked to setup.
task install_dependencies: :setup_environment do
  queue! %[sudo aptitude install git nginx libmysqlclient-dev -y]
end

# Install RVM from rvm.io recomendations
task install_rvm: :setup_environment do
  rvm_path  = "/home/#{user}/.rvm/bin/rvm"
  queue! %[gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3]
  queue! %[curl -sSL https://get.rvm.io | bash -s stable]
  queue! %[#{rvm_path} reload]
  queue! %[echo "export rvm_max_time_flag=20" >> ~/.rvmrc]
  queue! %[#{rvm_path} install #{ruby_version}]
  queue! %[#{rvm_path} all do gem install bundle]
end

task configure_nginx: :setup_environment do
  invoke :'nginx:setup'
  invoke :'nginx:parse'
  invoke :'nginx:link'
  invoke :'nginx:restart'
end

private
def nginx_template
  File.expand_path '../../samples/nginx.conf', __FILE__
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
