module Hitchspots
  # Fetch Coordinate arrays through external APIs
  module Coordinate
    # Using OSRM API, fetch coordinates for a trip having a start place and
    # finish place
    #
    # @param [Place] start_location A Place object to get geoloc for
    # @param [Place] finish_location A Place object to get geoloc for
    #
    # @return [Array] Array of coordinates: [[lon1, lat1], [lon2, lat2], ...]
    def self.for_trip(start_location, finish_location, api: :osrm)
      start_geo  = find_geolocation(start_location)
      finish_geo = find_geolocation(finish_location)

      case api
      when :osrm
        osrm_coordinates(start_geo, finish_geo)
      when :mapbox
        mapbox_coordinates(start_geo, finish_geo)
      else
        raise Error, "API wrapper #{api} not implemented"
      end
    end

    private_class_method def self.find_geolocation(place)
      if place.lat && place.lon
        { lat: place.lat, lon: place.lon }
      else
        Geolocation.find_by_place(place.name)
      end
    end

    # Rubocop bug: https://github.com/bbatsov/rubocop/issues/4431
    # rubocop:disable Layout/MultilineMethodCallIndentation
    private_class_method def self.osrm_coordinates(start_geo, finish_geo)
      trip = Osrm.trip(start_geo, finish_geo)

      # TODO: Not found should not be an exception
      raise NotFound, "No route found" if trip[:code] == "NoRoute"

      trip.fetch(:trips, [{}])
          .first
          .fetch(:geometry, {})
          .fetch(:coordinates, nil) || raise(ApiChanged, "Osrm API has changed")
    end
    # rubocop:enable Layout/MultilineMethodCallIndentation

    # Rubocop bug: https://github.com/bbatsov/rubocop/issues/4431
    # rubocop:disable Layout/MultilineMethodCallIndentation
    private_class_method def self.mapbox_coordinates(start_geo, finish_geo)
      trip = Mapbox.trip(start_geo, finish_geo)

      # TODO: Not found should not be an exception
      raise NotFound, "No route found" if trip[:code] == "NoRoute"

      trip.fetch(:routes, [{}])
          .first
          .fetch(:geometry, {})
          .fetch(:coordinates, nil) || raise(ApiChanged, "Mapbox API has changed")
    end
    # rubocop:enable Layout/MultilineMethodCallIndentation
  end
end
