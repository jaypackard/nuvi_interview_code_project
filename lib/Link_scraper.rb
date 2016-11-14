require 'open_uri_redirections'
require 'nokogiri'

module LinkScraper
  def parse_out_links(url, xpath, ext)
    url = append_dash_if_needed( canonical_url(url) )
    index_doc = Nokogiri::HTML( open(url) )
    urls = index_doc.search(xpath)
    files = urls.select{|l| l['href'] =~ /\.#{ext}/ } if ext
    files.map{|link| "#{url}#{link['href']}" }
  end

private
  def canonical_url(url)
    open(url, :allow_redirections => :safe) do |resp|
      resp.base_uri.to_s
    end
  end

  def append_dash_if_needed(url)
    return "#{url}/" if url !~ /.*\/$/
    return url
  end

end
