require "rollbar/rake_tasks"

desc "initialize rollbar"
task :environment do
  Rollbar.configure do |config|
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  end
end
