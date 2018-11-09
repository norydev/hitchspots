module Cacheable
  DEFAULT_EXPIRATION = 60 * 60

  private

  def maybe_cache(cache, key:)
    return yield unless cache

    expires_in = cache.is_a?(Integer) ? cache : DEFAULT_EXPIRATION

    Cache.fetch(key, expires_in: expires_in) { yield }
  end
end
