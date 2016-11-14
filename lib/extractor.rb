require 'zip/zip'

module Extractor
  BUFFER_SIZE = 100000

  def extract_from_url(zip_url, temp_dir)
    zip_file = download(zip_url, temp_dir)
    extract(zip_file, temp_dir)
  end

private
  def download(zip_url, temp_dir)
    puts "Downloading #{zip_url}"

    name = File.basename(zip_url, '.zip')
    zip_file = "#{temp_dir}/#{name}.zip"

    open(zip_url) do |input|
      output = File.open(zip_file, "wb")
      while (buffer = input.read(BUFFER_SIZE))
        output.write(buffer)
      end
      output.close
    end

    zip_file
  end

  def extract(zip_file, temp_dir)
    puts "Extracting #{zip_file}"

    name = File.basename(zip_file, '.zip')
    extract_dir = "#{temp_dir}/#{name}"
    Zip::ZipFile.open(zip_file) do |zip_file|
      zip_file.each do |f|
        f_path = File.join(extract_dir, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      end
    end
    extract_dir
  end

end

