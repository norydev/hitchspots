require_relative "test_helper"
require "./app"

class TripValidatorTest < Minitest::Test
  def setup
    stub_request(:get, %r{https\://api\.mapbox\.com/directions/v5/mapbox/driving/.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/mapbox_example.json"))
  end

  def assert_raise_validation_error(trip)
    assert_raises Hitchspots::ValidationError do
      Hitchspots::Trip::Validator.new(trip).validate!
    end
  end

  def test_too_many_places
    max = Hitchspots::Trip::Validator::MAX_NUMBER_OF_PLACES

    too_many_places = Array.new((max + 1)) do
      Hitchspots::Place.new("Berlin", lat: "1.23", lon: "2.34")
    end

    invalid_trip = Hitchspots::Trip.new(*too_many_places)

    error = assert_raise_validation_error(invalid_trip)
    assert_match(/Too many destinations, maximum is #{max}/, error.message)
  end

  def test_not_enough_places
    min = Hitchspots::Trip::Validator::MIN_NUMBER_OF_PLACES

    invalid_trip = Hitchspots::Trip.new(
      Hitchspots::Place.new("Berlin", lat: "1.23", lon: "2.34")
    )

    error = assert_raise_validation_error(invalid_trip)
    assert_match(/At least #{min} destinations needed/, error.message)
  end

  def test_no_coordinates
    stub_request(:get, %r{https\://api\.mapbox\.com/directions/v5/mapbox/driving\.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/mapbox_no_route_example.json"))

    invalid_trip = Hitchspots::Trip.new(
      Hitchspots::Place.new("List tiny village",  lat: "1.23", lon: "2.34"),
      Hitchspots::Place.new("Another lost place", lat: "4.56", lon: "5.67")
    )

    error = assert_raise_validation_error(invalid_trip)
    assert_match(/No route found/, error.message)
  end

  def test_place_not_found
    place = "Invalid Place"

    stub_request(:get, "https://nominatim.openstreetmap.org/search?format=json&limit=1&q=#{place}")
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/osm_no_place_example.json"))

    invalid_trip = Hitchspots::Trip.new(
      Hitchspots::Place.new(place),
      Hitchspots::Place.new("Valid Place", lat: "1.23", lon: "2.34")
    )

    error = assert_raise_validation_error(invalid_trip)
    assert_match(/#{place} not found/, error.message)
  end

  def test_no_spots
    invalid_trip = Hitchspots::Trip.new(
      Hitchspots::Place.new("Paris",  lat: "1.23", lon: "2.34"),
      Hitchspots::Place.new("Berlin", lat: "4.56", lon: "5.67")
    )

    error = assert_raise_validation_error(invalid_trip)
    assert_match(/No spots on this route/, error.message)
  end
end
