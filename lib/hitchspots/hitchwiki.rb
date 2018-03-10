require "net/http"
require "uri"
require "json"

module Hitchspots
  # Hitchwiki maps API wrapper
  # Documentation: https://hitchwiki.org/maps/, click API in bottom right corner
  module Hitchwiki
    BASE_URL = "https://hitchwiki.org/maps/api/".freeze

    # Get detail of a spots by it"s ID.
    # doc: https://hitchwiki.org/maps/ => #place_info paragraph
    #
    # @param [String] id ID of spot (Hitchwiki ID)
    #
    # @return [Hash] Spot detail, see test/doubles/responses/spot_example.json
    def self.spot(id)
      uri       = URI(BASE_URL)
      uri.query = URI.encode_www_form(place:  id,
                                      who:    "hitchspots.me",
                                      format: "json")

      res = Net::HTTP.get_response(uri)

      raise ApiError, "Hitchwiki unavailable" if res.code != "200"

      JSON.parse(res.body, symbolize_names: true)
    end

    # Get all the spots in a bounded area.
    # doc: https://hitchwiki.org/maps/ => #places_area paragraph
    #
    # @param [Float|Integer|String] bounds Four coordinates:
    #                                      lat_min, lat_max, lon_min, lon_max
    #
    # @return [Array:Hash] Array of spot hashes, contains
    #         { id: String, lat: String, lon: String, rating: String }
    def self.spots_by_area(*bounds)
      uri       = URI(BASE_URL)
      uri.query = URI.encode_www_form(bounds: bounds.join(","),
                                      who:    "hitchspots.me",
                                      format: "json")

      res = Net::HTTP.get_response(uri)

      raise ApiError, "Hitchwiki unavailable" if res.code != "200"

      JSON.parse(res.body, symbolize_names: true)
    end

    # Get all the spots in a bounded area.
    # doc: https://hitchwiki.org/maps/ => #places_country paragraph
    #
    # @param [String] country_iso_code ISO code of country
    #
    # @return [Array:Hash] Array of spot hashes, contains
    #         { id: String, lat: String, lon: String, rating: String }
    # rubocop:disable Metrics/MethodLength
    def self.spots_by_country(country_iso_code)
      uri       = URI(BASE_URL)
      uri.query = URI.encode_www_form(country: country_iso_code,
                                      who:     "hitchspots.me",
                                      format:  "json")

      res = Net::HTTP.get_response(uri)

      raise ApiError, "Hitchwiki unavailable" if res.code != "200"

      parsed_body = JSON.parse(res.body, symbolize_names: true)

      # TODO: Not found should not be an exception
      if parsed_body.is_a?(Hash) && parsed_body.fetch(:error_description, nil) == "No results."
        raise NotFound, "#{Hitchspots::Country::COUNTRIES[country_iso_code]} has no spots"
      end

      parsed_body
    end
    # rubocop:enable Metrics/MethodLength
  end
end
