require "net/http"
require "uri"
require "json"

module Hitchspots
  # Mapbox API wrapper
  # Documentation: https://www.mapbox.com/api-documentation/
  module Mapbox
    # Using Directions service, fetch trip data knowing start and finish locations.
    # doc: https://www.mapbox.com/api-documentation/#retrieve-directions
    #
    # @param [Array<Hash>] geolocs Array of Coordidates hash like { lat: 1.23455, lon: 9.87654 }
    #
    # @return [Hash] A Trip object from Mapbox
    def self.trip(geolocs)
      base_url = "https://api.mapbox.com/directions/v5/mapbox/driving/"
      points   = geolocs.map { |geoloc| "#{geoloc[:lon]},#{geoloc[:lat]}" }.join(";")
      uri      = URI("#{base_url}#{points}")

      uri.query = URI.encode_www_form(geometries: "geojson",
                                      access_token: ENV["MAPBOX_TOKEN"])

      res = Net::HTTP.get_response(uri)

      raise ApiError, "Mapbox unavailable" if res.code != "200"

      JSON.parse(res.body, symbolize_names: true)
    end
  end
end
