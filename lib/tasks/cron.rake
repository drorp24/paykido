namespace :cron do
  desc "Runs daily"
  task :daily => :environment do
    puts "Running daily"
  end
end
