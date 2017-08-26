module Hitchspots
  # Fetch Geolocation (lat, lon) for a place through an external API
  module Geolocation
    # Using external API, fetch geolocation coordinates for a given place
    #
    # @param [String] place_name A Place name that is geolocatable (city, etc)
    #
    # @return [Hash] A coordinates hash like { lat: 1.23456, lon: 9.87654 }
    def self.find_by_place(place_name)
      place = OpenStreetMap.geolocate(place_name)

      # TODO: Not found should not be an exception
      raise NotFound, "#{place_name} not found" if place.nil?

      { lat: place[:lat].to_f, lon: place[:lon].to_f }
    end
  end
end
