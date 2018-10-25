class HomePresenter
  def initialize(params = {})
    @params = params
  end

  def trip
    @trip ||= Hitchspots::Trip.new(
      places: [
        Hitchspots::Place.new(params.dig(:places, "0", :name),
                              lat: params.dig(:places, "0", :lat),
                              lon: params.dig(:places, "0", :lon)),
        Hitchspots::Place.new(params.dig(:places, "1", :name),
                              lat: params.dig(:places, "1", :lat),
                              lon: params.dig(:places, "1", :lon))
      ]
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
