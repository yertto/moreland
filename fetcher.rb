require 'date'
require 'open-uri'
require 'pathname'

module Fetcher

  CACHE_DIR = Pathname.new(".cache/#{Date.today.strftime('%y%m%d')}")

  def _get_cache_file_and_data(url, cache_dir)
    cache_dir.mkdir unless cache_dir.exist?
    cache_file = cache_dir.join(url.split('/')[-1])
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

  def get_cache_file(url, cache_dir=CACHE_DIR)
    _get_cache_file_and_data(url, cache_dir)[0]
  end

  def get_data(url, cache_dir=CACHE_DIR)
    _get_cache_file_and_data(url, cache_dir)[1]
  end
end
