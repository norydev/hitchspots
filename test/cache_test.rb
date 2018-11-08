require_relative "test_helper"
require "./app"

class CacheTest < Minitest::Test
  def test_set_value_in_redis
    from_redis = Cache.set("key", "value")

    assert_equal "OK", from_redis
  end

  def test_get_value_from_redis
    Cache.set("key", "value")

    from_redis = Cache.get("key")

    assert_equal "value", from_redis
  end

  def test_delete_value_in_redis
    Cache.set("key", "value")

    from_redis = Cache.delete("key")

    assert_equal 1, from_redis
    assert_nil   Cache.get("key")
  end

  def test_fetch_with_value_in_cache_no_block
    Cache.set("key", "value")

    from_redis = Cache.fetch("key")

    assert_equal "value", from_redis
  end

  def test_fetch_with_value_in_cache_with_block
    Cache.set("key", "value")

    from_redis = Cache.fetch("key") do
      raise "block is ignored"
    end

    assert_equal "value", from_redis
  end

  def test_fetch_no_value_in_cache_with_block
    Cache.delete("key")

    from_redis = Cache.fetch("key") { "value" }

    assert_equal "value", from_redis
  end

  def test_fetch_no_value_in_cache_no_block
    Cache.delete("key")

    from_redis = Cache.fetch("key")

    assert_nil from_redis
  end

  def test_fetch_cache_block_result
    Cache.delete("key")
    Cache.fetch("key") { "value" }

    from_redis = Cache.get("key")

    assert_equal "value", from_redis
  end

  def test_expired_value
    Cache.set("key", "old_value", expires_in: 10)

    assert_in_delta 10, Cache.redis.ttl("key"), 1
  end
end
