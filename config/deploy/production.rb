set :domain,  '104.130.124.233'
set :user,    'devlandia'
set :branch,  'master'

task deploy: :environment do
  deploy do
    invoke :'whenever:update'
  end
end
