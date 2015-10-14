module CarbonDispatch
  class Head
    include Middleware

    def call(request, response)
      app.call(request, response)

      if request.method == "HEAD"
        response.body.close
        response.body = BodyProxy.new("")
      end
    end
  end
end
