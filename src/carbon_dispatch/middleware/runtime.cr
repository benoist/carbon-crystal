module CarbonDispatch
  class Runtime < Middleware
    def initialize(name = nil)
      super()
      @header_name = "X-Runtime"
      @header_name += "-#{name}" if name
    end

    FORMAT_STRING = "%0.6f"

    def call(env)
      start_time            = Time.now
      status, headers, body = @app.call(env)
      request_time          = Time.now - start_time

      if !headers.has_key?(@header_name)
        headers[@header_name] = FORMAT_STRING % request_time
      end

      { status, headers, body }
    end
  end
end
