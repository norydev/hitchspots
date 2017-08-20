module Hitchspots
  class Error < StandardError; end
  class ApiChanged < Error; end
  class NotFound < Error; end
end
