require "json"
require "erb"
require "time"

module Hitchspots
  module Deprecated
    # Hitchhiking trip for which we would like to get the Hitchwiki maps spots
    class Trip
      attr_reader :from, :to

      # @param [Place] from Place object, origin of Trip
      # @param [Place] to   Place object, destination of Trip
      def initialize(from:, to:)
        @from = from
        @to   = to
      end

      def spots(format: nil)
        coords = Coordinate.for_deprecated_trip(from, to, api: :mapbox)
        bounds = areas(coords)
        spots  = find_spots(bounds)

        case format
        when :json then spots.to_json
        when :kml  then build_kml(spots, coordinates: coords)
        else            spots
        end
      end

      # Example: paris-berlin.kml
      def file_name(format: :txt)
        "#{from.short_name.downcase.gsub(/[^a-z]/, '_')}-"\
        "#{to.short_name.downcase.gsub(/[^a-z]/, '_')}.#{format}"
      end

      private

      def areas(coordinates)
        zones = []
        coordinates.each_with_index do |(this_lon, this_lat), i|
          next if i == 0

          prev_lon, prev_lat = *coordinates[i - 1]

          # Add about 10km on each side to overlap
          zones << [[this_lat, prev_lat].min - 0.1,
                    [this_lat, prev_lat].max + 0.1,
                    [this_lon, prev_lon].min - 0.1,
                    [this_lon, prev_lon].max + 0.1]
        end
        zones
      end

      def find_spots(zones)
        all_spots = Spot.in_area(*area_containing_zones(zones))

        spots = zones.map do |lat_min, lat_max, lon_min, lon_max|
          all_spots.select do |spot|
            within_lat = spot["lat"] >= lat_min && spot["lat"] <= lat_max
            within_lon = spot["lon"] >= lon_min && spot["lon"] <= lon_max

            within_lat && within_lon
          end
        end

        spots.flatten.uniq { |spot| spot["id"] }
      end

      def area_containing_zones(zones)
        area_lat_min = zones.map { |z| z[0] }.min
        area_lat_max = zones.map { |z| z[1] }.max
        area_lon_min = zones.map { |z| z[2] }.min
        area_lon_max = zones.map { |z| z[3] }.max

        [area_lat_min, area_lat_max, area_lon_min, area_lon_max]
      end

      def build_kml(spots, coordinates: nil)
        title       = "#{from.short_name} - #{to.short_name}"
        spots       = spots
        coordinates = coordinates
        time        = Time.now.utc.iso8601
        ERB.new(File.read("#{__dir__}/templates/mm_template.xml.erb"), 0, ">")
           .result(binding)
      end
    end
  end
end
