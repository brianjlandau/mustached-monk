require "uri/generic"

module URI
  class Redis < Generic
    DEFAULT_PORT = 6379

    COMPONENT = [:scheme, :password, :host, :port, :db].freeze

    def db
      path[1..-1].to_i
    end

    alias password user

  protected
    def check_path(value)
      if super(value)
      end
    end
  end

  @@schemes["REDIS"] = Redis
end
