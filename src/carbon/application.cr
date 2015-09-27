module Carbon
  class Application
    macro inherited
      Carbon.application = {{@type}}.new
      end

    macro config
      Carbon.application
    end

    macro views(*views)
      {% for view in views %}
          @actions[{{action}}.to_s] = ->{{action.id}}
      {% end %}
    end

    def initialize!
      set_default_middleware
      app = middleware.build
      @handler = CarbonDispatch::Handler.new(app)
    end

    def router=(router)
      @router = router
    end

    def router
      @router || raise "No routes set up"
    end

    def middleware
      @middleware ||= CarbonDispatch::MiddlewareStack::INSTANCE
    end

    def run
      server = create_server("127.0.0.1", 8080)
      server.listen
    end

    private def create_server(ip, port)
      handler = @handler
      raise "Application not initialized!" unless handler
      Carbon.logger.info "Carbon #{Carbon::VERSION} application starting in #{Carbon.env} on http://#{ip}:#{port}"

      HTTP::Server.new port, [handler]
    end

    private def set_default_middleware
      middleware.use CarbonDispatch::Sendfile.new "X-Accel-Redirect"
      middleware.use CarbonDispatch::Static.new
      middleware.use CarbonDispatch::Runtime.new
      middleware.use CarbonDispatch::RequestId.new
      middleware.use CarbonDispatch::Logger.new
    end
  end
end
