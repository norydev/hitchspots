require "json"
require "erb"
require "time"

module Hitchspots
  # Hitchhiking trip for which we would like to get the Hitchwiki maps spots
  class Country
    COUNTRIES = YAML.load_file("./data/countries.yml")

    attr_reader :name, :iso_code

    # @param [String] iso_code ISO code for country
    def initialize(iso_code)
      @iso_code = iso_code
      @name     = COUNTRIES.fetch(iso_code)
    end

    def spots
      @spots ||= Spot.in_country(iso_code)
    end

    # Example: finland.kml
    def file_name(format: :txt)
      "#{name.downcase.gsub(/[^a-z]/, '_')}.#{format}"
    end

    def kml_file
      title = name.to_s
      spots = self.spots
      time  = Time.now.utc.iso8601
      ERB.new(File.read("#{__dir__}/templates/mm_template.xml.erb"), trim_mode: ">")
         .result(binding)
    end
  end
end
