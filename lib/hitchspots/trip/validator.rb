module Hitchspots
  class Trip
    class Validator
      attr_reader :errors

      MIN_NUMBER_OF_PLACES = 2  # need at least origin & destination
      MAX_NUMBER_OF_PLACES = 25 # mapbox's max number of waypoints

      def initialize(trip)
        @trip = trip
        @errors = []
      end

      def validate
        _validate_min_number_of_places
        _validate_max_number_of_places

        begin
          _validate_has_coordinates
          _validate_has_spots
        rescue NotFound => e
          errors << { message: e.message }
        end

        errors.any? ? false : true
      end

      def validate!
        return if validate

        raise ValidationError, errors.map { |e| e[:message] }.join(", ")
      end

      private

      attr_reader :trip
      attr_writer :errors

      def _validate_min_number_of_places
        return if trip.places.size >= MIN_NUMBER_OF_PLACES

        errors << { message: "At least #{MIN_NUMBER_OF_PLACES} destinations needed" }
      end

      def _validate_max_number_of_places
        return if trip.places.size <= MAX_NUMBER_OF_PLACES

        errors << { message: "Too many destinations, maximum is #{MAX_NUMBER_OF_PLACES}" }
      end

      def _validate_has_coordinates
        return if trip.coordinates.any?

        errors << { message: "No route to find spots for" }
      end

      def _validate_has_spots
        return if trip.spots.any?

        errors << { message: "No spots on this route" }
      end
    end
  end
end
