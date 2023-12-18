module Hitchspots
  Dir.glob("#{__dir__}/hitchspots/*.rb").each { |f| require(f) }
  Dir.glob("#{__dir__}/hitchspots/trip/*.rb").each { |f| require(f) }
  Dir.glob("#{__dir__}/hitchspots/country/*.rb").each { |f| require(f) }
end
