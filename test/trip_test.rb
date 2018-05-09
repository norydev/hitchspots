require_relative "test_helper"
require "./app"

class TripTest < Minitest::Test
  def test_file_name
    trip = Hitchspots::Trip.new(
      places: [
        Hitchspots::Place.new("Berlin, city, Germany"),
        Hitchspots::Place.new("Paris, city, France")
      ]
    )

    assert_equal trip.file_name, "berlin-paris.txt"
  end
end
