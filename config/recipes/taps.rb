namespace :taps do

  desc "Run a taps server"
  # run like: cap rake:invoke task=a_certain_task
  task :start, :roles => :db do
    run("cd #{deploy_to}/current; taps server postgres://paykido@localhost/paykido tmpuser tmppass")
  end

end
