#!/usr/bin/env ruby

require_relative 'lib/link_scraper'
require_relative 'lib/redis_client'
require_relative 'lib/extractor'
require 'yaml'
require 'fileutils'

include LinkScraper
include Extractor

conf = YAML.load_file('conf/conf.yml')
redis = RedisClient.new(host: conf['redis_host'], port: conf['redis_port'])
FileUtils.mkdir_p conf['temp_dir']

links = parse_out_links(conf['xml_url'], conf['link_xpath'], 'zip')
links.each do |url|
  begin
    extract_dir = extract_from_url(url, conf['temp_dir'])
    redis.publish_files_in_dir(extract_dir)
  rescue StandardError => e
    puts "Skipping: #{e.message}"
  end
end


