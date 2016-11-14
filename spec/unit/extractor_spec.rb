require "minitest/autorun"
require 'open_uri_redirections'
require "./lib/extractor"

include Extractor

class TestRedisClientTest < Minitest::Test
  def test_that_zip_file_are_extracted
    dir = extract("./spec/fixtures/zip/xmls.zip", "/tmp")
    assert_equal dir, "/tmp/xmls"
    assert_equal File.exist?("#{dir}/test1.xml"), true
    assert_equal File.exist?("#{dir}/test2.xml"), true
  end

end
