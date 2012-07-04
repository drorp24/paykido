namespace :rake do
  desc "Run a task on a remote server."
  # run like: cap rake:invoke task=a_certain_task
  task :invoke, :roles => :web do
    run("cd #{deploy_to}/current; #{rake}  #{ENV['task']} RAILS_ENV=production")
  end
end
