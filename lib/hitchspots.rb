module Hitchspots
  Dir.glob("#{__dir__}/hitchspots/*.rb").sort.each { |f| require(f) }
  Dir.glob("#{__dir__}/hitchspots/trip/*.rb").sort.each { |f| require(f) }
  Dir.glob("#{__dir__}/hitchspots/country/*.rb").sort.each { |f| require(f) }
end
