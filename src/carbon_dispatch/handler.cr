module CarbonDispatch
  class Handler < HTTP::Handler
    def initialize(@app : Middleware)
    end

    def call(request : HTTP::Request) : HTTP::Response
      env = CarbonDispatch::Environment.new(request)
      status, headers, body = @app.call(env)
      HTTP::Response.new(status, body.to_s, headers).tap { body.close }
    end
  end
end
