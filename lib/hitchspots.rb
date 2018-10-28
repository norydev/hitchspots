module Hitchspots
  Dir.glob("#{__dir__}/hitchspots/*.rb") { |f| require(f) }
  Dir.glob("#{__dir__}/hitchspots/trip/*.rb") { |f| require(f) }
end
