require_relative "test_helper"
require "./app"

class CoordinateTest < Minitest::Test
  def setup
    stub_request(:get, %r{https\:\/\/nominatim\.openstreetmap\.org\/search\?.*})
      .to_return(status: 200,
                 body: File.read("#{__dir__}/doubles/responses/osm_example.json"))

    stub_request(:get, %r{https\:\/\/api\.mapbox\.com\/directions\/v5\/mapbox\/driving\/.*})
      .to_return(status: 200,
                 body: File.read("#{__dir__}/doubles/responses/mapbox_example.json"))

    stub_request(:get, %r{https\:\/\/router\.project\-osrm\.org\/trip\/v1\/driving\/.*})
      .to_return(status: 200,
                 body: File.read("#{__dir__}/doubles/responses/osrm_example.json"))
  end

  def test_for_trip_correct
    coords = Hitchspots::Coordinate.for_trip(
      [Hitchspots::Place.new("Berlin"), Hitchspots::Place.new("Paris")],
      api: :mapbox
    )

    assert_equal coords, JSON.parse(File.read("#{__dir__}/doubles/responses/coords_example.json"))
  end

  def test_for_trip_osrm
    coords = Hitchspots::Coordinate.for_trip(
      [Hitchspots::Place.new("Berlin"), Hitchspots::Place.new("Paris")],
      api: :osrm
    )

    assert_equal coords, JSON.parse(File.read("#{__dir__}/doubles/responses/coords_example.json"))
  end

  def test_for_trip_wrong_api
    assert_raises Hitchspots::Error do
      Hitchspots::Coordinate.for_trip(
        [Hitchspots::Place.new("Berlin"), Hitchspots::Place.new("Paris")],
        api: :unknown
      )
    end
  end

  def test_find_geolocation_existing_geoloc
    geo = Hitchspots::Coordinate.send(:find_geolocation,
                                      Hitchspots::Place.new(lat: 1.23, lon: 3.45))

    assert_equal geo, lat: 1.23, lon: 3.45
  end
end
