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

    # Fetch all spots of a country in Database
    #
    # @param [String] iso_code alpha2 code of a country (capitalized)
    #
    # @return [Array] A collection of detailed spots
    def self.in_country(iso_code)
      ::DB::Spot::Collection.find(
        "sanitized.location.country.iso" => iso_code
      ).to_a.map { |spot| spot.fetch("sanitized", nil) }.compact
    end

    def self.find(ids)
      if ids.is_a? Array
        ::DB::Spot::Collection.find(
          "sanitized.id" => { "$in" => ids }
        ).to_a.map { |spot| spot.fetch("sanitized", nil) }.compact
      else
        ::DB::Spot::Collection.find("sanitized.id" => ids)
                              .to_a.first.fetch("sanitized", nil)
      end
    end
  end
end
