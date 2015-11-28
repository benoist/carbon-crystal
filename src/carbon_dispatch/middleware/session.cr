module CarbonDispatch
  class Session
    include Middleware

    def call(request, response)
      app.call(request, response)
      request.session.set_cookie
    end
  end
end
