ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "minitest/color"
require "rack/test"
require "webmock/minitest"

require "./app"

WebMock.disable_net_connect!(allow_localhost: true)
