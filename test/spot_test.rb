require_relative "test_helper"
require "./app"

class SpotTest < Minitest::Test
  def test_fix_encoding
    spot = Hitchspots::Spot.new(id: "1", lat: "46.7635", lon: "6.643722",
                                location: { locality: "KÃ¶niz" },
                                description: {
                                  en_UK: {
                                    description: "TimiÈ™oara is a nice place"
                                  }
                                })

    fixed = spot.send(:fix_encoding, spot.info)

    assert_equal fixed[:encoded_name], "Köniz"
    assert_equal fixed[:encoded_desc], "Timișoara is a nice place"
  end
end
