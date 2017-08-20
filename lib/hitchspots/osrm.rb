require "net/http"
require "uri"
require "json"

module Hitchspots
  # Project OSRM API wrapper
  # Documentation: http://project-osrm.org/docs/v5.10.0/api/
  module Osrm
    # Using Trip service, fetch trip data knowing start and finish locations.
    # doc: http://project-osrm.org/docs/v5.10.0/api/#trip-service
    #
    # @param [Hash] start  Coordidates hash like { lat: 1.23455, lon: 9.87654 }
    # @param [Hash] finist Coordidates hash like { lat: 1.23455, lon: 9.87654 }
    #
    # @return [Hash] A Trip object from OSRM
    def self.trip(start, finish)
      base_url = "https://router.project-osrm.org/trip/v1/driving/"
      uri      = URI("#{base_url}#{start[:lon]},#{start[:lat]};"\
                     "#{finish[:lon]},#{finish[:lat]}")

      uri.query = URI.encode_www_form(source: "first",
                                      destination: "last",
                                      roundtrip: false,
                                      geometries: "geojson")

      res = Net::HTTP.get_response(uri)

      JSON.parse(res.body, symbolize_names: true)
    end
  end
end
