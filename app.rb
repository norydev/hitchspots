# frozen_string_literal: true

require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require "./lib/hitchspots"

set :public_folder, File.dirname(__FILE__) + '/public'

get "/" do
  erb(:home)
end

get "/trip" do
  begin
    trip = Hitchspots::Trip.new(from: params[:from], to: params[:to])
    maps_me_kml = trip.spots(format: :kml)

    content_type 'text/plain'
    attachment file_name(params[:from], params[:to])
    maps_me_kml
  rescue Hitchspots::NotFound => e
    @error = { not_found: e.message }
    erb(:home)
  rescue Hitchspots::Error => e
    @error = { external: true }
    erb(:home)
  end
end

def file_name(from, to)
  "#{from.downcase.gsub(/[^a-z]/, '-')}-#{to.downcase.gsub(/[^a-z]/, '-')}.kml"
end
