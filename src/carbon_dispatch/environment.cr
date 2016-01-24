module CarbonDispatch
  class Environment
    getter :request
    getter :errors
    property :request_id
    property :ip

    @request : ::HTTP::Request

    def initialize(@request)
      @errors = STDOUT
      @ip = "127.0.0.1" # TODO: fetch real IP
    end

    def [](value)
      @request.headers[value]
    end

    def []?(value)
      @request.headers[value]?
    end
  end
end
