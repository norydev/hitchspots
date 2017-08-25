require "json"

module Hitchspots
  # Hitchwiki maps spot
  class Spot
    attr_reader :id, :lat, :lon, :info

    def initialize(id:, lat: nil, lon: nil, **params)
      @id = id
      @lat = lat.to_f
      @lon = lon.to_f
      @info = params.merge(hw_id: @id, lat: @lat, lon: @lon)
    end

    # Fetch all spots in Database
    #
    # @return [Array] A collection of detailed spots
    def self.all(db: Sinatra::Application.settings.mongo_db)
      db.find.to_a
    end

    # Fetch spots in Database within a bounded area
    #
    # @param [Float] lat_min minimal latitude bound
    # @param [Float] lat_max maximal latitude bound
    # @param [Float] lon_min minimal longitude bound
    # @param [Float] lon_max maximal longitude bound
    #
    # @return [Array] A collection of detailed spots
    def self.in_area(lat_min, lat_max, lon_min, lon_max,
                     db: Sinatra::Application.settings.mongo_db)
      db.find({ lat: { "$gte" => lat_min, "$lte" => lat_max },
                lon: { "$gte" => lon_min, "$lte" => lon_max } }).to_a
    end

    def save(db: Sinatra::Application.settings.mongo_db)
      if db.find(hw_id: id).to_a.empty?
        db.insert_one fix_encoding(info)
      else
        update(db: db)
      end
      self
    end

    def update(db: Sinatra::Application.settings.mongo_db)
      db.find(hw_id: id).find_one_and_update("$set" => info)
      self
    end

    def destroy(db: Sinatra::Application.settings.mongo_db)
      db.find(hw_id: id).find_one_and_delete
      self
    end

    private

    # Fix encoding as it does not seem to work on the fly. Keep original API
    # data intact, push new encoded strings in new params
    #
    # This method should only be called once, as #encode and #force_encoding
    # are not idempotent.
    def fix_encoding(params)
      params.tap do |params|
        locality = params.fetch(:location, {}).fetch(:locality, nil)

        if locality
          begin
            new_locality = locality.encode("Windows-1252").force_encoding("utf-8")
            params[:encoded_name] = new_locality
          rescue Encoding::UndefinedConversionError
            # do nothing, ignore encoding correction
          end
        end

        desc = params.fetch(:description, {})
                     .fetch(:en_UK, {})
                     .fetch(:description, nil)

        if desc
          begin
            new_desc = desc.encode("Windows-1252").force_encoding("utf-8")
            params[:encoded_desc] = new_desc
          rescue Encoding::UndefinedConversionError
            # do nothing, ignore encoding correction
          end
        end
      end
    end
  end
end
