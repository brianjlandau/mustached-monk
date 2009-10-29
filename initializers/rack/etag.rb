require 'digest/sha1'

module Rack
  # Automatically sets the ETag header on all bodies using to_s
  class ETag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      if !headers.has_key?('ETag')
        headers['ETag'] = %("#{Digest::SHA1.hexdigest(body.to_s)}")
      end

      [status, headers, body]
    end
  end
end
