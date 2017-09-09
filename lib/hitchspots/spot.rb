require "json"

module Hitchspots
  # Hitchwiki maps spot
  module Spot
    # Fetch all spots in Database
    #
    # @return [Array] A collection of detailed spots
    def self.all
      ::DB::Spot::Collection.find.projection(sanitized: 1, _id: 0)
                            .to_a.map { |spot| spot.fetch("sanitized", nil) }
                            .compact
    end

    # Fetch spots in Database within a bounded area
    #
    # @param [Float] lat_min minimal latitude bound
    # @param [Float] lat_max maximal latitude bound
    # @param [Float] lon_min minimal longitude bound
    # @param [Float] lon_max maximal longitude bound
    #
    # @return [Array] A collection of detailed spots
    def self.in_area(lat_min, lat_max, lon_min, lon_max)
      ::DB::Spot::Collection.find(
        "sanitized.lat" => { "$gte" => lat_min, "$lte" => lat_max },
        "sanitized.lon" => { "$gte" => lon_min, "$lte" => lon_max }
      ).to_a.map { |spot| spot.fetch("sanitized", nil) }.compact
    end
  end
end
