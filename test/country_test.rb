require_relative "test_helper"
require "./app"

class CountryTest < Minitest::Test
  def setup
    stub_request(:get, %r{https://hitchwiki\.org/maps/api/\?country=FI.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/all_spots_example.json"))
  end

  def test_file_name
    country = Hitchspots::Country.new("FI")

    assert_equal country.file_name, "finland.txt"
  end

  def test_spot_ids_from_hitchwiki
    correct_ids = ["355", "182", "362", "365", "189", "193", "206", "372", "373", "721"]

    country = Hitchspots::Country.new("FI")

    assert_equal country.send(:spot_ids_from_hitchwiki), correct_ids
  end
end
