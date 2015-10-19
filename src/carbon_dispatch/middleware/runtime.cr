module CarbonDispatch
  class Runtime
    include Middleware

    def initialize(name = nil)
      super()
      header_name = "X-Runtime"
      header_name += "-#{name}" if name
      @header_name = header_name
    end

    FORMAT_STRING = "%0.6f"

    def call(request, response)
      start_time = Time.now
      app.call(request, response)
      request_time = Time.now - start_time

      if !response.headers.has_key?(@header_name)
        response.headers[@header_name] = FORMAT_STRING % request_time
      end
    end
  end
end
