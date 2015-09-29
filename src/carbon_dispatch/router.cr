require "./routing/**"

module CarbonDispatch
  class Router
    include Middleware
    macro inherited
      include CarbonDispatch::Routing::HttpRequestRouter
    end

  end
end
