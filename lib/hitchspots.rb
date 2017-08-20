module Hitchspots
  Dir.glob("#{__dir__}/hitchspots/*.rb") { |f| require(f) }
end
