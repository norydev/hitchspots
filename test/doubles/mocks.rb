require "json"

module Hitchspots
  module Mocks
    module Coordinate
      def self.for_trip(_start, _finish)
        JSON.parse(File.read("#{__dir__}/responses/coords_example.json"),
                   symbolize_names: true)
      end
    end

    module Geolocation
      def self.find_by_place(_place_name)
        { lat: 46.762828, lon: 6.645586 }
      end
    end

    # Hitchwiki:
    module Spot
      # area: http://hitchwiki.org/maps/api/?bounds=46.70,46.80,6.56,6.77&format=json
      def self.all
        JSON.parse(File.read("#{__dir__}/responses/all_spots_example.json"),
                   symbolize_names: true)
      end

      # NOTE: Unused yet
      # 1 spot: http://hitchwiki.org/maps/api/?place=18953
      def self.find(_id)
        JSON.parse(File.read("#{__dir__}/responses/spot_example.json"),
                   symbolize_names: true)
      end
    end

    # OpenStreetMap nominatim api:
    module OpenStreetMap
      def self.geolocate(_place_name)
        JSON.parse(File.read("#{__dir__}/responses/osm_example.json"),
                   symbolize_names: true).first
      end
    end

    # Project OSRM API:
    module Osrm
      def self.trip(_start, _finish)
        JSON.parse(File.read("#{__dir__}/responses/osrm_example.json"),
                   symbolize_names: true)
      end
    end

    # Mapbox API:
    module Mapbox
      def self.trip(_start, _finish)
        JSON.parse(File.read("#{__dir__}/responses/mapbox_example.json"),
                   symbolize_names: true)
      end
    end
  end
end
