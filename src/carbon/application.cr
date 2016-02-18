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
      set_key_generator
      set_default_middleware
      app = middleware.build
      @handler = CarbonDispatch::Handler.new(app)
    end

    def routes
      @router ||= CarbonDispatch::Router.new
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
      server = create_server(ENV["BIND"]? || "::1", 3000)
      server.listen
    end

    private def create_server(ip, port)
      handler = @handler
      raise "Application not initialized!" unless handler
      Carbon.logger.info "Carbon #{Carbon::VERSION} application starting in #{Carbon.env} on http://#{ip}:#{port}"

      HTTP::Server.new(ip, port, [handler])
    end

    private def set_key_generator
      secrets = (YAML.parse(File.read(Carbon.root.join("config/secrets.yml").to_s).to_s) as Hash(String, String))[Carbon.env.to_s.downcase] as Hash(String, String)
      secret_key_base = ENV["SECRET_KEY_BASE"]? || secrets["secret_key_base"].to_s
      Carbon.key_generator = CarbonSupport::CachingKeyGenerator.new(CarbonSupport::KeyGenerator.new(secret_key_base, 1000))
    end

    private def set_default_middleware
      middleware.use CarbonDispatch::Sendfile.new "X-Accel-Redirect"
      middleware.use CarbonDispatch::Static.new
      middleware.use CarbonDispatch::Runtime.new
      middleware.use CarbonDispatch::RequestId.new
      middleware.use CarbonDispatch::Logger.new
      middleware.use CarbonDispatch::ShowExceptions.new
      middleware.use CarbonDispatch::Head.new
      middleware.use CarbonDispatch::Cookies.new
      middleware.use CarbonDispatch::Session.new
      middleware.use CarbonDispatch::Flash.new
    end
  end
end
