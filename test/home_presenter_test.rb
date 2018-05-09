require_relative "test_helper"
require "./app"

class HomePresenterTest < Minitest::Test
  def test_empty_trip
    home = HomePresenter.new
    places = home.trip.places

    [:name, :lat, :lon].each do |attr|
      assert_nil places[0].public_send(attr)
      assert_nil places[-1].public_send(attr)
    end
  end

  def test_empty_country
    home = HomePresenter.new

    assert_equal home.country.iso_code, "AF"
    assert_equal home.country.country_name, "Afghanistan"
  end

  def test_trip_with_params
    home = HomePresenter.new(from: "Here", from_lat: "1.234", from_lon: "2.324",
                             to:   "Da",   to_lat:   "3.456", to_lon:   "4.567")

    from = home.trip.places[0]

    assert_equal from.name, "Here"
    assert_equal from.lat,  "1.234"
    assert_equal from.lon,  "2.324"
  end

  def test_country_with_params
    home = HomePresenter.new(iso_code: "CH")

    assert_equal home.country.iso_code, "CH"
    assert_equal home.country.country_name, "Switzerland"
  end

  def test_empty_error
    home = HomePresenter.new

    assert_nil home.error
  end

  def test_error_with_params
    home = HomePresenter.new(error_msg: "not found")

    assert_equal home.error, message: "not found"
  end
end
