require_relative "test_helper"
require "./app"

class TripTest < Minitest::Test
  def test_file_name
    trip = Hitchspots::Trip.new(
      Hitchspots::Place.new("Berlin, city, Germany"),
      Hitchspots::Place.new("Paris, city, France")
    )

    assert_equal "berlin-paris.txt", trip.file_name
  end
end
