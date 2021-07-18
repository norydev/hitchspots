source "https://rubygems.org"

ruby "2.6.8"

gem "puma"
gem "rake"
gem "sinatra"

# Mongo DB
gem "bson_ext"
gem "mongo"

# Tools
gem "rollbar"

group :development do
  gem "dotenv"
  gem "rb-fsevent"
  gem "rerun"
end

group :test do
  gem "minitest", "~> 5.0"
  gem "minitest-color"
  gem "rack-test"
  gem "webmock"
end

group :development, :test do
  gem "pry-byebug"
  gem "rubocop"
  gem "rubocop-minitest"
  gem "rubocop-rake"
end
