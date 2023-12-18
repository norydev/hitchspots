require_relative "test_helper"
require_relative "base_test"
require "./app"

class DeprecatedTripTest < BaseTest
  def test_file_name
    trip = Hitchspots::Deprecated::Trip.new(
      from: Hitchspots::Place.new("Berlin, city, Germany"),
      to:   Hitchspots::Place.new("Paris, city, France")
    )

    assert_equal "berlin-paris.txt", trip.file_name
  end
end
