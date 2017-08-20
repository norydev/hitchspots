require "net/http"
require "uri"
require "json"

module Hitchspots
  # OpenStreetMap Nominatim API wrapper
  # Documentation: http://wiki.openstreetmap.org/wiki/Nominatim
  module OpenStreetMap
    # Using Search service, fetch geolocation for a place.
    # doc: http://wiki.openstreetmap.org/wiki/Nominatim#Search
    #
    # @param [String] place_name A Place name that is geolocatable (city, etc)
    #
    # @return [Hash] Search result Object from OpenStreetMap
    def self.geolocate(place_name)
      uri       = URI("https://nominatim.openstreetmap.org/search")
      uri.query = URI.encode_www_form(q: place_name, limit: 1, format: "json")

      res = Net::HTTP.get_response(uri)

      JSON.parse(res.body, symbolize_names: true).first
    end
  end
end
