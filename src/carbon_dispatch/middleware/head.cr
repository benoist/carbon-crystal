module CarbonDispatch
  class Head
    include Middleware

    def call(request, response)
      app.call(request, response)

      if request.method == "HEAD"
        response.close
      end
    end
  end
end
