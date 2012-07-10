namespace :taps do

  desc "Run a taps server"
  # run like: cap rake:invoke task=a_certain_task
  task :start, :roles => :db do
    run("cd #{deploy_to}/current; bundle exec taps server postgres://#{postgresql_user}:#{postgresql_password}@localhost/#{postgresql_database} tapsuser tapspass")
  end

end
