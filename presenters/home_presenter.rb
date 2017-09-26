class HomePresenter
  def initialize(params = {})
    @params = params
  end

  def trip
    @trip ||= Hitchspots::Trip.new(
      from: Hitchspots::Place.new(params[:from],
                                  lat: params[:from_lat],
                                  lon: params[:from_lon]),
      to:   Hitchspots::Place.new(params[:to],
                                  lat: params[:to_lat],
                                  lon: params[:to_lon])
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
