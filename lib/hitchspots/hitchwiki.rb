require "net/http"
require "uri"
require "json"

module Hitchspots
  # Hitchwiki maps API wrapper
  # Documentation: https://hitchwiki.org/maps/, click API in bottom right corner
  module Hitchwiki
    extend ::Cacheable

    BASE_URL = "https://hitchwiki.org/maps/api/".freeze
    BASE_OPTIONS = { who: "hitchspots.me", format: "json" }.freeze

    class << self
      # Get detail of a spots by it"s ID.
      # doc: https://hitchwiki.org/maps/ => #place_info paragraph
      #
      # @param [String] id ID of spot (Hitchwiki ID)
      #
      # @return [Hash] Spot detail, see test/doubles/responses/spot_example.json
      def spot(id, cache: false)
        response = maybe_cache(cache, key: "hitchwiki/spot/#{id}") do
          api_request(place: id)
        end

        JSON.parse(response, symbolize_names: true)
      end

      # Get all the spots in a bounded area.
      # doc: https://hitchwiki.org/maps/ => #places_area paragraph
      #
      # @param [Float|Integer|String] bounds Four coordinates:
      #                                      lat_min, lat_max, lon_min, lon_max
      #
      # @return [Array:Hash] Array of spot hashes, contains
      #         { id: String, lat: String, lon: String, rating: String }
      def spots_by_area(*bounds, cache: false)
        joined_bounds = bounds.join(",")

        response = maybe_cache(cache, key: "hitchwiki/area/#{joined_bounds}") do
          api_request(bounds: joined_bounds)
        end

        JSON.parse(response, symbolize_names: true)
      end

      # Get all the spots in a bounded area.
      # doc: https://hitchwiki.org/maps/ => #places_country paragraph
      #
      # @param [String] country_iso_code ISO code of country
      #
      # @return [Array:Hash] Array of spot hashes, contains
      #         { id: String, lat: String, lon: String, rating: String }
      def spots_by_country(country_iso_code, cache: false)
        response = maybe_cache(cache, key: "hitchwiki/country/#{country_iso_code}") do
          api_request(country: country_iso_code)
        end

        parsed_body = JSON.parse(response, symbolize_names: true)

        if parsed_body.is_a?(Hash) && parsed_body.fetch(:error_description, nil) == "No results."
          return []
        end

        parsed_body
      end

      private

      def api_request(options)
        uri       = URI(BASE_URL)
        uri.query = URI.encode_www_form(BASE_OPTIONS.merge(options))

        res = Net::HTTP.get_response(uri)

        raise ApiError, "Hitchwiki unavailable" if res.code != "200"

        res.body
      end
    end
  end
end
