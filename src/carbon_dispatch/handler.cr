module CarbonDispatch
  class Handler < HTTP::Handler
    def call(request)
      Carbon.application.router.route(request)
    end
  end
end
