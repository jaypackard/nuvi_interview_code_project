#!/usr/bin/env ruby

require 'yaml'
require 'timeout'
require './lib/redis_client'

TIMEOUT = 60

pid = Process.spawn('./nuvi.rb')
begin
  Timeout.timeout(TIMEOUT) do
    Process.wait(pid)
  end
rescue Timeout::Error
  Process.kill('TERM', pid)
end

conf = YAML.load_file('conf/conf.test.yml')
redis = RedisClient.new(host: conf['redis_host'], port: conf['redis_port'])

Dir.foreach( conf['temp_dir'] ) do |d|
  next if d == '.' or d == '..'
  full_d = "#{conf['temp_dir']}/#{d}"
  if File.directory?(full_d)
    Dir.foreach( full_d ) do |f|
      next if f == '.' or f == '..'
      hash = File.basename(f, '.xml')
      if !redis.sismember('NEWS_HASHES', hash)
        puts "Failed: #{hash} not found" 
        exit
      end
    end
  end
end

puts "Success"