module CarbonDispatch
  class Handler < HTTP::Handler
    def initialize(@app : Middleware)
    end

    def call(context : HTTP::Server::Context)
      # env = CarbonDispatch::Environment.new(request)
      request = Request.new(context.request)
      response = Response.new(context.response)
      @app.call(request, response)
      response.finish
    end
  end
end
