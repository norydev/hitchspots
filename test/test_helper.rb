ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "minitest/color"
require "rack/test"
require "webmock/minitest"
require "database_cleaner/mongo"

require "./app"

DatabaseCleaner[:mongo].db = Sinatra::Application.settings.base_db
WebMock.disable_net_connect!(allow_localhost: true)
