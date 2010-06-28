require 'date'
require 'open-uri'
require 'pathname'

module Fetcher

  CACHE_DIR = Pathname.new(".cache/#{Date.today.strftime('%y%m%d')}")
  CACHE_DIR.mkdir unless CACHE_DIR.exist?

  def _get_cache_file_and_data(url)
    cache_file = CACHE_DIR.join(url.split('/')[-1])
    data = if cache_file.exist?
      STDERR.puts "Reading data from #{cache_file} ..."
      cache_file.read
    else
      cache_file.open('w') { |f|
        data = open(URI.escape(url)).read
        STDERR.puts "Caching data to #{cache_file} ..."
        f.write(data)
        data
      }
    end
    [cache_file, data]
  end

  def get_cache_file(url)
    _get_cache_file_and_data(url)[0]
  end

  def get_data(url)
    _get_cache_file_and_data(url)[1]
  end
end
