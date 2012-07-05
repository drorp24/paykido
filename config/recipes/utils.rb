namespace :utils do
  desc "tail production log files"
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      trap("INT") { puts 'Interupted'; exit 0; }
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

desc "Remote console on the production appserver"
task :console, :roles => ENV['ROLE'] || :web do
  hostname = find_servers_for_task(current_task).first
  puts "Connecting to #{hostname}"
  exec "ssh -l #{user} #{hostname} -t 'source ~/.profile && cd #{current_path} && bundle exec rails c #{rails_env}'"
end


end
