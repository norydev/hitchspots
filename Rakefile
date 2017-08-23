require "./app"

namespace :hitchwiki do
  desc "Harvest all spots on Hitchwiki"
  task :harvest do
    spots = Hitchspots::Hitchwiki.spots_by_area(-90, 90, -180, 180)

    spots.each do |spot|
      detailed_spot = Hitchspots::Hitchwiki.spot(spot[:id])
      hitchspot = Hitchspots::Spot.new(detailed_spot)
      hitchspot.save
    end
  end

  desc "Update spots from Hitchwiki"
  task :refresh do
    db_ids = Hitchspots::Spot.all.map { |s| s["hw_id"] }

    hitchwiki_spots = Hitchspots::Hitchwiki.spots_by_area(-90, 90, -180, 180)
    hitchwiki_ids = hitchwiki_spots.map { |s| s[:id] }

    # add spots by missing ids
    (hitchwiki_ids - db_ids).each do |hw_id|
      detailed_spot = Hitchspots::Hitchwiki.spot(hw_id)
      hitchspot = Hitchspots::Spot.new(detailed_spot)
      hitchspot.save
    end

    # delete spots by removed ids
    (db_ids - hitchwiki_ids).each do |hw_id|
      hitchspot = Hitchspots::Spot.new(id: hw_id)
      hitchspot.destroy
    end
  end
end
