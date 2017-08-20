require "json"
require "erb"
require "time"

module Hitchspots
  # Hitchhiking trip for which we would like to get the Hitchwiki maps spots
  class Trip
    attr_reader :from, :to

    def initialize(from:, to:)
      @from = from
      @to   = to
    end

    def spots(format: nil)
      coords = Coordinate.for_trip(from, to)
      bounds = areas(coords)
      spots  = find_spots(bounds)

      case format
      when :json then spots.to_json
      when :kml  then build_kml(spots)
      else            spots
      end
    end

    private

    def areas(coordinates)
      bounds = []
      coordinates.each_with_index do |(this_lon, this_lat), i|
        next if i == 0

        prev_lon, prev_lat = *coordinates[i - 1]

        # Add about 10km on each side to overlap
        bounds << [[this_lat, prev_lat].min - 0.1,
                   [this_lat, prev_lat].max + 0.1,
                   [this_lon, prev_lon].min - 0.1,
                   [this_lon, prev_lon].max + 0.1]
      end
      bounds
    end

    def find_spots(bounds)
      spots = bounds.map do |lat_min, lat_max, lon_min, lon_max|
        Spot.all.select do |spot|
          within_lat = spot[:lat].to_f >= lat_min && spot[:lat].to_f <= lat_max
          within_lon = spot[:lon].to_f >= lon_min && spot[:lon].to_f <= lon_max

          within_lat && within_lon
        end
      end

      spots.flatten.uniq { |spot| spot[:id] }
    end

    def build_kml(spots)
      title = "#{from} - #{to}"
      spots = spots
      time  = Time.now.utc.iso8601
      ERB.new(File.read("#{__dir__}/templates/mm_template.xml.erb"), 0, ">")
         .result(binding)
    end
  end
end
