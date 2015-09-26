module Carbon
  class Application
    macro inherited
      Carbon.application = {{@type}}.new
    end

    macro views(*views)
      {% for view in views %}
          @actions[{{action}}.to_s] = ->{{action.id}}
      {% end %}
    end

    def initialize!
    end

    def router=(router)
      @router = router
    end

    def router
      @router || raise "No routes set up"
    end

    def run
      server = create_server("127.0.0.1", 8080)
      server.listen
    end

    private def create_server(ip, port)
      Carbon.logger.info "Listening: http://#{ip}:#{port}"

      HTTP::Server.new port, [
                               HTTP::ErrorHandler.new,
                               HTTP::LogHandler.new,
                               HTTP::StaticFileHandler.new(Carbon.root.join("/public")),
                               CarbonDispatch::Handler.new,
                           ]
    end
  end
end
