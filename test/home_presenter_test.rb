require_relative "test_helper"
require "./app"

class HomePresenterTest < Minitest::Test
  def test_empty_trip
    home = HomePresenter.new
    origin = home.trip.places.first
    destination = home.trip.places.last

    [:name, :lat, :lon].each do |attr|
      assert_nil origin.public_send(attr)
      assert_nil destination.public_send(attr)
    end
  end

  def test_empty_country
    home = HomePresenter.new

    assert_equal "AF", home.country.iso_code
    assert_equal "Afghanistan", home.country.name
  end

  def test_trip_with_params
    home = HomePresenter.new(places: {
      "0" => { name: "Here", lat: "1.234", lon: "2.324" },
      "1" => { name: "Da", lat: "3.456", lon: "4.567" }
    })

    assert_equal "Here", home.trip.places.first.name
    assert_equal "1.234",  home.trip.places.first.lat
    assert_equal "2.324",  home.trip.places.first.lon
  end

  def test_country_with_params
    home = HomePresenter.new(iso_code: "CH")

    assert_equal "CH", home.country.iso_code
    assert_equal "Switzerland", home.country.name
  end

  def test_empty_error
    home = HomePresenter.new

    assert_nil home.error
  end

  def test_error_with_params
    home = HomePresenter.new(error_msg: "not found")

    assert_equal({ message: "not found" }, home.error)
  end
end
