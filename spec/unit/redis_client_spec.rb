require "minitest/autorun"
require "./lib/redis_client"

class MockRedis < RedisClient
  def initialize
    @hashes = []
  end

  def sismember(key, hash)
    @hashes.include?(hash)
  end

  def sadd(key, hash)
    @hashes << hash
  end

end

class TestRedisClientTest < Minitest::Test
  def setup
    @redis = MockRedis.new
  end

  def test_that_each_file_in_dir_is_published_once
    mock = Minitest::Mock.new
    mock.expect(:rpush, nil, ["NEWS_XML", "<xml>Test 1</xml>\n"])
    mock.expect(:rpush, nil, ["NEWS_XML", "<xml>Test 2</xml>\n"])
    @redis.stub :rpush, -> (key, value) {mock.rpush key, value} do
      @redis.publish_files_in_dir  "./spec/fixtures/xml"
      @redis.publish_files_in_dir  "./spec/fixtures/xml"
    end
    assert mock.verify
  end

end
