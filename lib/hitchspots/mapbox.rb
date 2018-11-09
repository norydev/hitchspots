require "net/http"
require "uri"
require "json"

module Hitchspots
  # Mapbox API wrapper
  # Documentation: https://www.mapbox.com/api-documentation/
  module Mapbox
    extend ::Cacheable

    BASE_URL = "https://api.mapbox.com/directions/v5/mapbox/driving/".freeze

    class << self
      # Using Directions service, fetch trip data knowing start and finish locations.
      # doc: https://www.mapbox.com/api-documentation/#retrieve-directions
      #
      # @param [Array<Hash>] geolocs Array of Coordidates hash like { lat: 1.23455, lon: 9.87654 }
      #
      # @return [Hash] A Trip object from Mapbox
      def trip(geolocs, cache: false)
        points   = geolocs.map { |geoloc| "#{geoloc[:lon]},#{geoloc[:lat]}" }.join(";")

        response = maybe_cache(cache, key: "mapbox/directions/#{points}") do
          uri       = URI("#{BASE_URL}#{points}")
          uri.query = URI.encode_www_form(geometries:   "geojson",
                                          access_token: ENV["MAPBOX_TOKEN"])

          res = Net::HTTP.get_response(uri)

          raise ApiError, "Mapbox unavailable" if res.code.to_i >= 500

          res.body
        end

        JSON.parse(response, symbolize_names: true)
      end
    end
  end
end
