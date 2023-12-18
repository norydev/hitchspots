require_relative "test_helper"
require_relative "base_test"

class AppTest < BaseTest
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    super

    stub_request(:get, %r{https://nominatim\.openstreetmap\.org/search\?.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/osm_example.json"))

    stub_request(:get, %r{https://api\.mapbox\.com/directions/v5/mapbox/driving/.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/mapbox_example.json"))

    stub_request(:get, %r{https://hitchwiki\.org/maps/api/\?country=FI.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/all_spots_example.json"))
  end

  def test_home
    get "/"

    assert_predicate last_response, :ok?
  end

  def test_trip
    get "/trip", from: "Paris", to: "Berlin"

    assert_predicate last_response, :ok?
    assert_equal "299 hitchspots.me/trip \"Deprecated\"", last_response.headers["Warning"]
  end

  def test_v2_trip
    get "/v2/trip", places: { "0" => { name: "Paris" }, "1" => { name: "Berlin" } }

    assert_predicate last_response, :ok?
  end

  def test_country
    get "/country", name: "Finland", iso_code: "FI"

    assert_predicate last_response, :ok?
  end
end
