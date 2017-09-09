require "rake/testtask"
require "./app"

Dir.glob("./lib/tasks/*.rake").each { |r| import r }

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
  t.warning = false
end

desc "Look for style guide offenses in your code"
task :rubocop do
  sh "rubocop --format simple || true"
end

task default: [:rubocop, :test]
