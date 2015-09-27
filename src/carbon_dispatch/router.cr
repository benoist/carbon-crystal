require "./routing/**"

module CarbonDispatch
  class Router < Middleware
    macro inherited
      include CarbonDispatch::Routing::HttpRequestRouter
    end

  end
end
