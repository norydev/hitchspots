require "rake/testtask"
require "rollbar/rake_tasks"
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

# For Rollbar:
task :environment do
  Rollbar.configure do |config|
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  end
end

namespace :hitchwiki do
  desc "Harvest all spots on Hitchwiki"
  task :harvest do
    spots = Hitchspots::Hitchwiki.spots_by_area(-90, 90, -180, 180)

    spots.each do |spot|
      detailed_spot = Hitchspots::Hitchwiki.spot(spot[:id])
      hitchspot = DB::Spot.new(detailed_spot)
      hitchspot.insert
    end
  end

  desc "Update spots from Hitchwiki"
  task :refresh do
    db_ids = DB::Spot.all.map { |s| s.fetch("raw", {}).fetch("id", nil) }.compact

    hitchwiki_spots = Hitchspots::Hitchwiki.spots_by_area(-90, 90, -180, 180)
    hitchwiki_ids = hitchwiki_spots.map { |s| s[:id] }

    # add spots by missing ids
    (hitchwiki_ids - db_ids).each do |hw_id|
      detailed_spot = Hitchspots::Hitchwiki.spot(hw_id)
      hitchspot = DB::Spot.new(detailed_spot)
      hitchspot.insert
    end

    # delete spots by removed ids
    (db_ids - hitchwiki_ids).each do |hw_id|
      hitchspot = DB::Spot.new(id: hw_id)
      hitchspot.destroy
    end
  end
end
