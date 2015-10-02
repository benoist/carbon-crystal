module CarbonDispatch
  module Middleware
    def call(request : Request, response : Response)
      app.call(request)
    end

    def build(app)
      @app = app
      self
    end

    def app
      @app || raise "App not defined"
    end
  end

  class MiddlewareStack
    INSTANCE = new

    def self.instance
      INSTANCE
    end

    def initialize
      @middleware = [] of CarbonDispatch::Middleware
    end

    def use(middleware : CarbonDispatch::Middleware)
      @middleware << middleware
    end

    def build
      app = Carbon.application.router
      @middleware.reverse.each do |middleware|
        app = middleware.build(app)
      end
      app
    end

    def to_s(io : IO)
      msg = super
      @middleware.each do |mdware|
        msg += "use #{mdware}\n"
      end
      io << msg
    end
  end
end
