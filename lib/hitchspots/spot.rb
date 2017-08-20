require "json"

module Hitchspots
  # Hitchwiki maps spot
  module Spot
    # Fetch all spots from HitchWiki Maps
    #
    # Note: Because it would require a lot of API call, the entire dataset has
    # been saved locally
    #
    # @return [Array] A collection of spots like
    # [{ lat: "1.23456", lon: "9.87654", id: "123", rating: "1" }, ...]
    def self.all
      JSON.parse(File.read("./world.json"), symbolize_names: true)
    end
  end
end
