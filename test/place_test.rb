require_relative "test_helper"
require_relative "base_test"
require "./app"

class PlaceTest < BaseTest
  def test_short_name_for_existing_name
    place = Hitchspots::Place.new("Istanbul, city, Turkey")

    assert_equal "Istanbul", place.short_name
  end

  def test_short_name_for_already_short_name
    place = Hitchspots::Place.new("Istanbul")

    assert_equal "Istanbul", place.short_name
  end

  def test_short_name_for_nil_name
    place = Hitchspots::Place.new

    assert_nil place.short_name
  end
end
