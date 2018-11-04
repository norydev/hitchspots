module Hitchspots
  class Country
    class Validator
      attr_reader :errors

      def initialize(country)
        @country = country
        @errors = []
      end

      def validate
        _validate_has_spots

        errors.any? ? false : self
      end

      def validate!
        return if validate

        raise ValidationError, errors.map { |e| e[:message] }.join(", ")
      end

      def full_error_message
        errors.map { |e| e[:message] }.join(", ")
      end

      private

      attr_reader :country
      attr_writer :errors

      def _validate_has_spots
        return if country.spots.any?

        errors << { message: "#{country.name} has no spots" }
      end
    end
  end
end
