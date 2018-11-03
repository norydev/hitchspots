require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require "rollbar/middleware/sinatra"
use Rollbar::Middleware::Sinatra

require "./lib/hitchspots"
Dir.glob("./presenters/*.rb") { |f| require(f) }

set :public_folder, File.dirname(__FILE__) + "/public"

configure :test do
  Mongo::Logger.logger.level = ::Logger::FATAL

  db = Mongo::Client.new(["127.0.0.1:27017"], database: "hitchspots-test")
  set :mongo_db, db[:spots]
end

configure :development do
  Dotenv.load

  db = Mongo::Client.new(["127.0.0.1:27017"], database: "hitchspots")
  set :mongo_db, db[:spots]
  set :show_exceptions, false
end

configure :production do
  db = Mongo::Client.new(ENV["MONGODB_URI"])
  set :mongo_db, db[:spots]

  Rollbar.configure do |config|
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
    config.environment = Sinatra::Base.environment
    config.framework = "Sinatra: #{Sinatra::VERSION}"
    config.root = Dir.pwd
  end
end

# Need DB configuration before requiring DB class
require "./lib/db/spot"

get "/" do
  @home = HomePresenter.new

  erb(:home)
end

get "/trip" do
  begin
    trip = Hitchspots::Deprecated::Trip.new(
      from: Hitchspots::Place.new(params[:from],
                                  lat: params[:from_lat],
                                  lon: params[:from_lon]),
      to:   Hitchspots::Place.new(params[:to],
                                  lat: params[:to_lat],
                                  lon: params[:to_lon])
    )

    maps_me_kml = trip.spots(format: :kml)

    response.headers["Warning"] = "299 hitchspots.me/trip \"Deprecated\""
    content_type "application/vnd.google-earth.kml+xml"
    attachment trip.file_name(format: :kml)
    maps_me_kml
  rescue Hitchspots::NotFound => e
    @home = HomePresenter.new(params.merge(error_msg: e.message))
    erb(:home)
  end
end

get "/v2/trip" do
  begin
    trip = Hitchspots::Trip.new(
      places: params[:places].sort_by { |index, _| index.to_i }.map do |_, place|
        Hitchspots::Place.new(place[:name], lat: place[:lat], lon: place[:lon])
      end
    )

    Hitchspots::Trip::Validator.new(trip).validate!

    content_type "application/vnd.google-earth.kml+xml"
    attachment   trip.file_name(format: :kml)
    trip.kml_file
  rescue Hitchspots::ValidationError => e
    @home = HomePresenter.new(params.merge(error_msg: e.message))
    erb(:home)
  end
end

get "/country" do
  begin
    country = Hitchspots::Country.new(params[:iso_code])

    maps_me_kml = country.kml_file

    content_type "application/vnd.google-earth.kml+xml"
    attachment country.file_name(format: :kml)
    maps_me_kml
  rescue Hitchspots::NotFound => e
    @home = HomePresenter.new(params.merge(error_msg: e.message))
    erb(:home)
  end
end

error do
  msg = "Sorry, our service is unavailable at the moment, "\
        "please try again later"
  @home = HomePresenter.new(params.merge(error_msg: msg))
  erb(:home)
end
