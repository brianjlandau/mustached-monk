module Rack
  module Cache
    class MetaStore
      class RedisBase < MetaStore
        extend Rack::Utils

        # The ::MarshaledRedis object used to communicate with the Redis daemon.
        attr_reader :cache

        def self.resolve(uri)
          db = uri.path.sub(/^\//, '')
          db = "0" if db.empty?
          server = { :host => uri.host, :port => uri.port || "6379", :db => db }
          new server
        end
      end

      class Redis < RedisBase
        def initialize(server, options = {})
          @cache = ::MarshaledRedis.new server
        end

        def read(key)
          key = hexdigest(key)
          cache.get(key) || []
        end

        def write(key, entries)
          key = hexdigest(key)
          cache.set(key, entries)
        end

        def purge(key)
          cache.delete(hexdigest(key))
          nil
        end
      end

      REDIS = Redis
    end
  end
end
