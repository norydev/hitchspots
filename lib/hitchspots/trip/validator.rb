module Hitchspots
  class Trip
    class Validator
      MIN_NUMBER_OF_PLACES = 2  # need at least origin & destination
      MAX_NUMBER_OF_PLACES = 25 # mapbox's max number of waypoints

      def initialize(trip)
        @trip = trip
      end

      def validate!
        _validate_min_number_of_places
        _validate_max_number_of_places
      end

      private

      attr_reader :trip

      def _validate_min_number_of_places
        return if trip.places.size >= MIN_NUMBER_OF_PLACES

        raise ValidationError, "At least #{MIN_NUMBER_OF_PLACES} destinations needed"
      end

      def _validate_max_number_of_places
        return if trip.places.size <= MAX_NUMBER_OF_PLACES

        raise ValidationError, "Too many destinations, maximum is #{MAX_NUMBER_OF_PLACES}"
      end
    end
  end
end
