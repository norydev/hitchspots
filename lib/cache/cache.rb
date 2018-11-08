module Cache
  class << self
    def get(key)
      redis.get(key)
    end

    def set(key, value, expires_in: nil)
      if expires_in
        redis.setex(key, expires_in, value)
      else
        redis.set(key, value)
      end
    end

    def delete(key)
      redis.del(key)
    end

    def fetch(key, expires_in: nil)
      value = get(key)
      return value if value

      value = yield if block_given?
      set(key, value, expires_in: expires_in) if value

      value
    end

    def redis
      @redis ||= Redis.new(url: ENV["REDIS_URL"], password: ENV["REDIS_PASS"])
    end
  end
end
