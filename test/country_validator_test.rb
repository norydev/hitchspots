require_relative "test_helper"
require_relative "base_test"
require "./app"

class CountryValidatorTest < BaseTest
  def test_no_spots
    invalid_country = Hitchspots::Country.new("CM")

    stub_request(:get, %r{https://hitchwiki\.org/maps/api/\?country=CM.*})
      .to_return(status: 200,
                 body:   File.read("#{__dir__}/doubles/responses/hitchwiki_no_spots_example.json"))

    error = assert_raises Hitchspots::ValidationError do
      Hitchspots::Country::Validator.new(invalid_country).validate!
    end
    assert_match(/#{invalid_country.name} has no spots/, error.message)
  end
end
