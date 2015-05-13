# Wise Elephant - Reports

## About the application

The application is made with Ruby Language, using essencially Sinatra Framework with ActiveRecord, and is divided in 2 parts: A collect of rake tasks to read databases and insert into anoter, and a collect of HTTP routes to provide reports on different levels. Instead the deploy server is running NGINX to proxy http requests to unicorn.

Some additional gems are used, listed bellow:

* Unicorn (web server)
* ActiveSupport (mainly additional Date features)
* Whenever (CRON jobs abstraction)
* Mina (Deploy)

All gems used are listed on Gemfile.

## Running locally

After clone the repository using git, in a shell, with your own user:

```
$ sudo aptitude install git nginx libmysqlclient-dev -y
$ \curl -sSL https://get.rvm.io | bash
$ source ~/.bashrc
$ rvm install 2.2.0
$ bundle install
$ unicorn
```

## Routes

The HTTP routes system is made with Sinatra Framework, and the routes definition is found in app/controllers/routes.rb. The follow routes are available:

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
Read orders infos from tusks database and insert on orders_by_day table.

### db:update_orders_table
Read hits infos from wiseleph_hattans database and insert on hits_by_day table.

## CRON Jobs
Both rake tasks are scheduled at CRON, running at the first minute of the day.
The CRON tab is managed by the gem Whenever, and the definitions can be found at config/schedule.rb
