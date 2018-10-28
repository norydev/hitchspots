require_relative "test_helper"
require "./app"

class TripValidatorTest < Minitest::Test
  def test_too_many_places
    invalid_trip = Hitchspots::Trip.new(
      places: Array.new((Hitchspots::Trip::Validator::MAX_NUMBER_OF_PLACES + 1)) do
        Hitchspots::Place.new("Berlin, city, Germany")
      end
    )

    assert_raises Hitchspots::ValidationError do
      Hitchspots::Trip::Validator.new(invalid_trip).validate!
    end
  end

  def test_not_enough_places
    invalid_trip = Hitchspots::Trip.new(
      places: [Hitchspots::Place.new("Berlin, city, Germany")]
    )

    assert_raises Hitchspots::ValidationError do
      Hitchspots::Trip::Validator.new(invalid_trip).validate!
    end
  end
end
