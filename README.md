# Wise Elephant - Reports

## The application

This application is made using Ruby Language. Its core is essentially the Sinatra Framework and ActiveRecord.  Its structure has two parts: 
1- A collection of rake tasks to pull information from the client databases and push it into the reporter database; 
2- A collection of HTTP routes that provide reports on different levels. 

The deploy server is using NGINX to proxy HTTP requests to unicorn.

Some additional gems used are listed bellow:
* Unicorn (Web server)
* ActiveSupport (Utility classes and Ruby extensions from Rails)
* Whenever (Cron jobs in Ruby)
* Mina (Fast deployer and server automation tool)

If you need more information, every used gems are listed on Gemfile.

## Running locally

Run those commands after cloning the repository using git, in a shell, with your user:

```
$ sudo aptitude install git nginx libmysqlclient-dev -y
$ \curl -sSL https://get.rvm.io | bash
$ source ~/.bashrc
$ rvm install 2.2.0
$ bundle install
$ unicorn
```

## Routes

The HTTP routes system are made using Sinatra Framework. All the routes definitions are found in app/controllers/routes.rb. The following routes are available:

* http://<your-server-name>/health
* http://<your-server-name>/dashboard
* http://<your-server-name>/source/<source-display-name>
* http://<your-server-name>/tracker/<tracker-name>

## Rake tasks

You can check the available tasks with

```
$ rake -vT
```

### db:update_hits_table
Read orders infos from tusks database and insert into orders_by_day table.

### db:update_orders_table
Read hits infos from wiseleph_hattans database and insert into hits_by_day table.

## CRON Jobs
Both rake tasks are scheduled in the CRON, running at the first minute of each day.
The CRON tab is managed by the gem Whenever, and the definitions can be found at config/schedule.rb
