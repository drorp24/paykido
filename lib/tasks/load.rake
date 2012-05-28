namespace :db do
  desc "Seed the database"
  task :load => :environment do
    Rake::Task['db:fixtures:load'].invoke
  end
end