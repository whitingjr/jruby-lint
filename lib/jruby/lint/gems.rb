require 'net/https'

module JRuby::Lint
  module Gems
    class Cache
      def initialize(cache_dir = nil)
        @cache_dir = cache_dir || (defined?(Gem.user_dir) && File.join(Gem.user_dir, 'lint'))
      end

      def fetch(name)
        filename = filename_for(name)
        if File.file?(filename)
          File.read(filename)
        else
          read_from_wiki(name, filename)
        end
      end

      def store(name, content)
        File.open(filename_for(name), "w") {|f| f << content }
      end

      def filename_for(name)
        name = File.basename(name)
        File.join(@cache_dir, File.extname(name).empty? ? "#{name}.html" : name)
      end

      def read_from_wiki(name, filename)
        content = nil
        uri = Net::HTTP.start('wiki.jruby.org', 80) do |http|
          URI.parse http.head(name =~ %r{^/} ? name : "/#{name}")['Location']
        end
        if uri.host == "github.com"
          Net::HTTP.new(uri.host, uri.port).tap do |http|
            if uri.scheme == "https"
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_PEER
              # gd_bundle.crt from https://certs.godaddy.com/anonymous/repository.seam
              http.ca_file = File.expand_path('../github.crt', __FILE__)
            end
            http.start do
              response = http.get(uri.path)
              content = response.body
              File.open(filename, "w") do |f|
                f << content
              end
            end
          end
        end
        raise "Unknown location '#{uri}' for page '#{name}'" unless content
        content
      rescue => e
        raise "Error while reading from wiki: #{e.message}\nPlease try again later."
      end
    end

    class CExtensions
      def initialize(cache)
        @cache = cache
      end
    end
  end
end
