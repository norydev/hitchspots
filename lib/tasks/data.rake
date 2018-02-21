# Tasks to migrate data in mongoDB
# Warning!! Only run each migration once
# rubocop:disable Metrics/BlockLength
namespace :data do
  desc "save raw as one value and sanitized as another"
  task :separate_raw_and_sanitized do
    DB::Spot.all.each do |spot|
      temp_spot = symbolize_keys(spot)
      temp_spot[:id]  = temp_spot[:hw_id]
      temp_spot[:lat] = temp_spot[:lat].to_s
      temp_spot[:lon] = temp_spot[:lon].to_s
      temp_spot.delete_if do |key, _|
        [:_id, :hw_id, :encoded_name, :encoded_desc].include? key
      end

      spot = DB::Spot.new(temp_spot)
      spot.save
    end
  end

  desc "delete old record that are not in raw/sanitized format"
  task :delete_non_sanitized do
    DB::Spot::Collection.delete_many(raw: nil, sanitized: nil)
  end

  desc "escape html"
  task :escape_html do
    DB::Spot::Collection.find.projection("raw" => 1, _id: 0).to_a
                        .map { |s| symbolize_keys(s.fetch("raw")) }
                        .each do |spot|
      temp_spot = DB::Spot.new(spot)
      temp_spot.save
    end
  end
end
# rubocop:enable Metrics/BlockLength

# rubocop:disable Metrics/MethodLength
def symbolize_keys(hash)
  Hash[
    hash.map do |key, value|
      new_key = case key
                when String then key.to_sym
                else             key
                end
      new_value = case value
                  when Hash  then symbolize_keys(value)
                  when Array then value.map { |v| symbolize_keys(v) }
                  else            value
                  end

      [new_key, new_value]
    end
  ]
end
# rubocop:enable Metrics/MethodLength
