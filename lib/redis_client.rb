require 'redis'

class RedisClient < Redis
  def publish_files_in_dir(dir)     
    Dir.foreach(dir) do |f|
      next if f !~ /\.xml$/
      publish_file("#{dir}/#{f}")
    end
  end

private
  def publish_file(filepath)
    hash = File.basename(filepath, '.xml')
    if !sismember('NEWS_HASHES', hash)
      file = File.open(filepath, "r")
      content = file.read
      rpush('NEWS_XML', content) 
      sadd('NEWS_HASHES', hash)
      file.close
    end
  end
end
