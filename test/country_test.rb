require_relative "test_helper"
require "./app"

class CountryTest < Minitest::Test
  def setup
    DB::Spot::Collection.delete_many

    spot_file = File.read("#{__dir__}/doubles/responses/spot_example.json")
    spot_example = JSON.parse(spot_file, symbolize_names: true)

    finland_spots = 5.times.map do |n|
      spot_example.merge(id: 100 + n, location: { country: { iso: "FI" } })
    end
    other_countries_spots = 5.times.map do |n|
      spot_example.merge(id: 200 + n, location: { country: { iso: "CH" } })
    end

    [*finland_spots, *other_countries_spots].each { |spot| DB::Spot.new(**spot).save }
  end

  def test_file_name
    country = Hitchspots::Country.new("FI")

    assert_equal country.file_name, "finland.txt"
  end

  def test_spot_ids_from_hitchwiki
    correct_ids = [100, 101, 102, 103, 104]

    country = Hitchspots::Country.new("FI")

    assert_equal country.spots.map { |spot| spot["id"] }, correct_ids
  end
end
