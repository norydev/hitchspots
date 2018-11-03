module Hitchspots
  # Fetch Coordinate arrays through external APIs
  module Coordinate
    class << self
      # Using OSRM API, fetch coordinates for a trip having a start place and
      # finish place
      #
      # @param [Place] start_location A Place object to get geoloc for
      # @param [Place] finish_location A Place object to get geoloc for
      #
      # @return [Array] Array of coordinates: [[lon1, lat1], [lon2, lat2], ...]
      def for_deprecated_trip(start_location, finish_location, api: :osrm)
        start_geo  = find_geolocation(start_location)
        finish_geo = find_geolocation(finish_location)

        case api
        when :osrm
          osrm_coordinates([start_geo, finish_geo])
        when :mapbox
          mapbox_coordinates([start_geo, finish_geo])
        else
          raise Error, "API wrapper #{api} not implemented"
        end
      end

      # Using OSRM API, fetch coordinates for a trip having a start place and
      # finish place
      #
      # @param [Array<Place>] locations Array of Place objects to get geoloc for
      #
      # @return [Array] Array of coordinates: [[lon1, lat1], [lon2, lat2], ...]
      def for_trip(locations, api: :osrm)
        geolocs = locations.map { |place| find_geolocation(place) }

        case api
        when :osrm
          osrm_coordinates(geolocs)
        when :mapbox
          mapbox_coordinates(geolocs)
        else
          raise Error, "API wrapper #{api} not implemented"
        end
      end

      private

      def find_geolocation(place)
        if place.lat && place.lon
          { lat: place.lat, lon: place.lon }
        else
          Geolocation.find_by_place(place.name)
        end
      end

      def osrm_coordinates(geolocations)
        trip = Osrm.trip(geolocations)
        # TODO: Not found should not be an exception
        raise NotFound, "No route found" if trip[:code] == "NoRoute"

        trip.fetch(:trips, [{}])
            .first
            .fetch(:geometry, {})
            .fetch(:coordinates, nil) || raise(ApiChanged, "Osrm API has changed")
      end

      def mapbox_coordinates(geolocations)
        trip = Mapbox.trip(geolocations)

        raise NotFound, trip[:message] unless trip[:code] == "Ok"

        trip.fetch(:routes, [{}])
            .first
            .fetch(:geometry, {})
            .fetch(:coordinates, nil) || raise(ApiChanged, "Mapbox API has changed")
      end
    end
  end
end
