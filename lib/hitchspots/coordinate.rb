module Hitchspots
  # Fetch Coordinate arrays through external APIs
  module Coordinate
    # Using OSRM API, fetch coordinates for a trip having a start place and
    # finish place
    #
    # @param [String] start_location A city, village, place to get geoloc for
    # @param [String] finish_location A city, village, place to get geoloc for
    #
    # @return [Array] Array of coordinates: [[lon1, lat1], [lon2, lat2], ...]
    def self.for_trip(start_location, finish_location, api: :osrm)
      start_geo  = Geolocation.find_by_place(start_location)
      finish_geo = Geolocation.find_by_place(finish_location)

      case api
      when :osrm
        osrm_coordinates(start_geo, finish_geo)
      when :mapbox
        mapbox_coordinates(start_geo, finish_geo)
      else
        raise NotFound, "API wrapper #{api} not implemented"
      end
    end

    private_class_method def self.osrm_coordinates(start_geo, finish_geo)
      trip = Osrm.trip(start_geo, finish_geo)

      trip.fetch(:trips, [{}]).first
          .fetch(:geometry, {})
          .fetch(:coordinates, nil) || raise(ApiChanged, "Osrm API has changed")
    end

    private_class_method def self.mapbox_coordinates(start_geo, finish_geo)
      trip = Mapbox.trip(start_geo, finish_geo)

      trip.fetch(:routes, [{}]).first
          .fetch(:geometry, {})
          .fetch(:coordinates, nil) || raise(ApiChanged, "Mapbox API has changed")
    end
  end
end
