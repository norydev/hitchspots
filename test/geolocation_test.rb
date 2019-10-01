require_relative "test_helper"
require "./app"

class GeolocationTest < Minitest::Test
  def setup
    stub_request(:get, %r{https\:\/\/nominatim\.openstreetmap\.org\/search\?.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/osm_example.json"))
  end

  def test_find_by_place
    place = Hitchspots::Geolocation.find_by_place("Cologne")

    assert_equal place[:lat], 50.938361
    assert_equal place[:lon], 6.959974
  end
end
