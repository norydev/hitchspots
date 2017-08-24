# frozen_string_literal: true

require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require "./lib/hitchspots"

set :public_folder, File.dirname(__FILE__) + '/public'

configure :development do
  db = Mongo::Client.new(["127.0.0.1:27017"], database: "hitchspots")
  set :mongo_db, db[:spots]
  set :show_exceptions, false
end

configure :production do
  db = Mongo::Client.new(ENV["MONGODB_URI"])
  set :mongo_db, db[:spots]
end

get "/" do
  erb(:home)
end

get "/trip" do
  trip = Hitchspots::Trip.new(from: params[:from], to: params[:to])
  maps_me_kml = trip.spots(format: :kml)

  content_type 'text/plain'
  attachment file_name(params[:from], params[:to])
  maps_me_kml
end

error Hitchspots::NotFound do
  @error = { message: env["sinatra.error"].message }
  erb(:home)
end

error do
  @error = { message: "Sorry, our service is unavailable at the moment, "\
                      "please try again later" }
  erb(:home)
end

def file_name(from, to)
  "#{from.downcase.gsub(/[^a-z]/, '-')}-#{to.downcase.gsub(/[^a-z]/, '-')}.kml"
end
