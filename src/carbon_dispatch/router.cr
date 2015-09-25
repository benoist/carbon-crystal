require "./routing/**"

module CarbonDispatch
  class Router
    macro inherited
      include CarbonDispatch::Routing::HttpRequestRouter
    end

  end
end
