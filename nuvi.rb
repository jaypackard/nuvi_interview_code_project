#!/usr/bin/env ruby

require 'open_uri_redirections'
require 'nokogiri'
require 'zip/zip'
require 'tempfile'
require 'redis'

BUFFER_SIZE = 100000

def canonical_url(url)
  open(url, :allow_redirections => :safe) do |resp|
    ret = resp.base_uri.to_s
    ret = "#{ret}/" if ret !~ /.*\/$/
    return ret
  end
end

def parse_out_links(url)
  index_doc = Nokogiri::HTML( open(url) )
  index_doc.search('table tr td a').select{|l| l['href'] =~ /\.zip$/}
end

def download_file(url, filepath)
  open(url) do |input|
    output = File.open(filepath, "wb")
    while (buffer = input.read(BUFFER_SIZE))
      output.write(buffer)
    end
    output.close
  end
rescue OpenURI::HTTPError => e
  puts "skipping: #{e.message}"
end

def unzip(zip_filepath, unzipped_dir)
  Zip::ZipFile.open(zip_filepath) do |zip_file|
    zip_file.each do |f|
      f_path = File.join(unzipped_dir, f.name)
      FileUtils.mkdir_p(File.dirname(f_path))
      zip_file.extract(f, f_path) unless File.exist?(f_path)
    end
  end
end

def publish(redis, filepath)
  hash = File.basename(filepath, '.xml')
  if !redis.sismember('NEWS_HASHES', hash)
    file = File.open(filepath, "r")
    content = file.read
    redis.rpush('NEWS_XML', content) 
    redis.sadd('NEWS_HASHES', hash)
    file.close
  end
end

def main
  redis = Redis.new

  canonical_url = canonical_url('http://bitly.com/nuvi-plz')
  parse_out_links(canonical_url).each do |link|
    zip_name = link['href']
    zip_url = "#{canonical_url}#{zip_name}"
    zip_file = "/tmp/#{zip_name}"
    unzipped_dir = zip_file.gsub(/\.zip$/, '')

    puts "Handling #{zip_name}"

    download_file(zip_url, zip_file)

    unzip(zip_file, unzipped_dir)

    Dir.foreach(unzipped_dir) do |f|
      next if f == '.' or f == '..'
      publish(redis, "#{unzipped_dir}/#{f}")
    end
  end
end

main()

