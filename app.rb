require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require "rollbar/middleware/sinatra"
use Rollbar::Middleware::Sinatra

require "./lib/hitchspots"

set :public_folder, File.dirname(__FILE__) + "/public"

configure do
  Rollbar.configure do |config|
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
    config.environment = Sinatra::Base.environment
    config.framework = "Sinatra: #{Sinatra::VERSION}"
    config.root = Dir.pwd
  end
end

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
end

get "/" do
  @trip = Hitchspots::Trip.new(from: Hitchspots::Place.new,
                               to:   Hitchspots::Place.new)

  erb(:home)
end

get "/trip" do
  trip = Hitchspots::Trip.new(
    from: Hitchspots::Place.new(params[:from],
                                lat: params[:from_lat],
                                lon: params[:from_lon]),
    to:   Hitchspots::Place.new(params[:to],
                                lat: params[:to_lat],
                                lon: params[:to_lon])
  )

  maps_me_kml = trip.spots(format: :kml)

  content_type "text/plain"
  attachment trip.file_name(format: :kml)
  maps_me_kml
end

error Hitchspots::NotFound do
  @error = { message: env["sinatra.error"].message }
  @trip = Hitchspots::Trip.new(
    from: Hitchspots::Place.new(params[:from],
                                lat: params[:from_lat],
                                lon: params[:from_lon]),
    to:   Hitchspots::Place.new(params[:to],
                                lat: params[:to_lat],
                                lon: params[:to_lon])
  )
  erb(:home)
end

error do
  @error = { message: "Sorry, our service is unavailable at the moment, "\
                      "please try again later" }
  @trip = Hitchspots::Trip.new(
    from: Hitchspots::Place.new(params[:from],
                                lat: params[:from_lat],
                                lon: params[:from_lon]),
    to:   Hitchspots::Place.new(params[:to],
                                lat: params[:to_lat],
                                lon: params[:to_lon])
  )
  erb(:home)
end
