class HomePresenter
  def initialize(params = {})
    @params = params
    @params[:places] ||= { "0" => {}, "1" => {} }
  end

  def trip
    @trip ||= Hitchspots::Trip.new(
      places: params.fetch(:places).sort_by { |index, _| index.to_i }.map do |_, place|
        Hitchspots::Place.new(place[:name], lat: place[:lat], lon: place[:lon])
      end
    )
  end

  def country
    @country ||= Hitchspots::Country.new(params[:iso_code] || "AF")
  end

  def error
    @error ||= params[:error_msg] ? { message: params[:error_msg] } : nil
  end

  private

  attr_reader :params
end
