module Hitchspots
  require_relative "hitchspots/cacheable"

  Dir.glob("#{__dir__}/hitchspots/*.rb") { |f| require(f) }
  Dir.glob("#{__dir__}/hitchspots/trip/*.rb") { |f| require(f) }
  Dir.glob("#{__dir__}/hitchspots/country/*.rb") { |f| require(f) }
end
