module CarbonDispatch
  class Request
    def session
      @session ||= Request::Session.new(cookie_jar)
    end
  end

  class Session
    include Middleware

    def call(request, response)
      app.call(request, response)
      request.session.set_cookie
    end
  end
end
