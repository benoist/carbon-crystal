module CarbonDispatch
  class Handler < HTTP::Handler
    def initialize(@app : Middleware)
    end

    def call(request : HTTP::Request) : HTTP::Response
      # env = CarbonDispatch::Environment.new(request)
      request = Request.new(request)
      response = Response.new
      @app.call(request, response)

      # HTTP::Response.new(response.status, body.to_s, headers).tap { body.close }
      response.to_http_response
    end
  end
end
