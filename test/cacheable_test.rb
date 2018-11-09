require_relative "test_helper"
require "./app"

class CacheableTest < Minitest::Test
  include Cacheable

  def setup
    Cache.delete("key")
    Cache.set("key", "value")
  end

  def test_maybe_cache_no_cache
    response = maybe_cache(false, key: "key") { "foo" }

    assert_equal "foo", response
  end

  def test_maybe_cache_with_cache_true
    maybe_cache(true, key: "key") { "foo" }

    assert_equal    "foo", Cache.get("key")
    assert_in_delta Cacheable::DEFAULT_EXPIRATION, Cache.redis.ttl("key"), 1
  end

  def test_maybe_cache_with_cache_integer
    maybe_cache(10, key: "key") { "foo" }

    assert_equal    "foo", Cache.get("key")
    assert_in_delta 10, Cache.redis.ttl("key"), 1
  end
end
