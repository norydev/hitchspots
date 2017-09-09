require_relative "test_helper"
require "./app"

class DbSpotTest < Minitest::Test
  def test_re_encoding
    spot = ::DB::Spot.new(id: "1", lat: "46.7635", lon: "6.643722",
                          location: { locality: "KÃ¶niz" },
                          description: {
                            en_UK: {
                              description: "TimiÈ™oara is a nice place"
                            }
                          })

    sanitized = spot.data[:sanitized]

    assert_equal sanitized[:location][:locality], "Köniz"
    assert_equal sanitized[:description][:en_UK][:description], "Timișoara is a nice place"
  end
end
