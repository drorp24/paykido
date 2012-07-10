require "bundler/capistrano"

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/postgresql"
load "config/recipes/nodejs"
load "config/recipes/rbenv"
load "config/recipes/check"
load "config/recipes/utils"
load "config/recipes/rake"
load "config/recipes/taps"

server "50.116.63.241", :web, :app, :db, primary: true

set :user, "deployer"
set :password, "deployerpass2412"

set :application, "paykido"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:drorp24/paykido.git" #"https://github.com/drorp24/paykido.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = false
# ssh_options[:verbose] = :debug
# ssh_options[:username] = 'deployer'
# ssh_options[:host_key] = 'ssh-dss'


after "deploy", "deploy:cleanup" # keep only the last 5 releases
