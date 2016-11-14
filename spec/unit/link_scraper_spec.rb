require "minitest/autorun"
require 'open_uri_redirections'
require "./lib/link_scraper"

include LinkScraper

class TestRedisClientTest < Minitest::Test
  def test_that_zip_links_are_parsed
    html = File.open("./spec/fixtures/html/index.html", "r").read
    OpenURI.stub :open_uri, html do
      stub :canonical_url, "http://dummy.com" do
        urls = parse_out_links("dummy", "table tr td a", "zip")
        assert_equal urls, ["http://dummy.com/link1.zip", "http://dummy.com/link2.zip"]
      end
    end
  end

end
