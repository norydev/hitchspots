require "rake/testtask"
require "./app"

Dir.glob("./lib/tasks/*.rake").each { |r| import r }

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
  t.warning = false
end

task default: [:test]
