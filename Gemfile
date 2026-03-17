source "https://rubygems.org"

ruby file: ".ruby-version"

gem "puma"
gem "rake"
gem "rackup"
gem "sinatra"

# Mongo DB
gem "mongo"
gem "bigdecimal" # looks like we need this explicitly?

# Tools
gem "rollbar"

group :development do
  gem "dotenv"
  gem "rb-fsevent"
  gem "rerun"
end

group :test do
  gem "database_cleaner-mongo"
  gem "minitest"
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
