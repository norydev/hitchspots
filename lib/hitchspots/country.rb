require "json"
require "erb"
require "time"

module Hitchspots
  # Hitchhiking trip for which we would like to get the Hitchwiki maps spots
  class Country
    COUNTRIES = YAML.load_file("./data/countries.yml")

    attr_reader :country_name, :iso_code

    # @param [String] iso_code ISO code for country
    def initialize(iso_code)
      @iso_code = iso_code
      @country_name = COUNTRIES.fetch(iso_code)
    end

    def spots(format: nil)
      spots = find_spots

      case format
      when :json then spots.to_json
      when :kml  then build_kml(spots)
      else            spots
      end
    end

    # Example: finland.kml
    def file_name(format: :txt)
      "#{country_name.downcase.gsub(/[^a-z]/, '_')}.#{format}"
    end

    private

    def find_spots
      ids = spot_ids_from_hitchwiki

      Spot.find(ids)
    end

    def spot_ids_from_hitchwiki
      Hitchwiki.spots_by_country(iso_code).map { |spot| spot[:id] }
    end

    def build_kml(spots)
      title = country_name.to_s
      spots = spots
      time  = Time.now.utc.iso8601
      ERB.new(File.read("#{__dir__}/templates/mm_template.xml.erb"), 0, ">")
         .result(binding)
    end
  end
end
