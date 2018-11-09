require "net/http"
require "uri"
require "json"

module Hitchspots
  # OpenStreetMap Nominatim API wrapper
  # Documentation: https://wiki.openstreetmap.org/wiki/Nominatim
  module OpenStreetMap
    extend ::Cacheable

    # Using Search service, fetch geolocation for a place.
    # doc: https://wiki.openstreetmap.org/wiki/Nominatim#Search
    #
    # @param [String] place_name A Place name that is geolocatable (city, etc)
    #
    # @return [Hash] Search result Object from OpenStreetMap
    def self.geolocate(place_name, cache: false)
      response = maybe_cache(cache, key: "open_street_map/place/#{place_name}") do
        uri       = URI("https://nominatim.openstreetmap.org/search")
        uri.query = URI.encode_www_form(q: place_name, limit: 1, format: "json")

        res = Net::HTTP.get_response(uri)

        raise ApiError, "OpenStreetMap unavailable" if res.code != "200"

        res.body
      end

      JSON.parse(response, symbolize_names: true).first
    end
  end
end
