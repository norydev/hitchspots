require_relative "test_helper"
require "./app"

class DbSpotTest < Minitest::Test
  def setup
    DB::Spot::Collection.delete_many
  end

  def test_re_encoding
    spot = DB::Spot.new(id: "1", lat: "46.7635", lon: "6.643722",
                        location: { locality: "KÃ¶niz" },
                        description: {
                          en_UK: {
                            description: "TimiÈ™oara is a nice place"
                          }
                        })

    sanitized = spot.data[:sanitized]

    assert_equal "Köniz", sanitized[:location][:locality]
    assert_equal "Timișoara is a nice place", sanitized[:description][:en_UK][:description]
  end

  def test_update
    spot = DB::Spot.new(id: "1", lat: "3.444", location: { locality: "KÃ¶niz" })

    spot.save

    spot = DB::Spot.new(id: "1", location: { locality: "Yverdon" })

    spot.save

    retrieved = DB::Spot::Collection.find("raw.id" => "1").to_a.first

    assert_equal "Yverdon", retrieved["sanitized"]["location"]["locality"]
    assert_equal 1, DB::Spot.all.size
  end
end
