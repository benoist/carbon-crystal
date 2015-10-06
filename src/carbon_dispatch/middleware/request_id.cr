module CarbonDispatch
  class RequestId
    include Middleware
    def call(request, response)
      request_id = external_request_id(request) || internal_request_id
      app.call(request, response)
      response.headers["X-Request-Id"] = request_id.to_s
    end

    private def external_request_id(request)
      if request_id = request.headers["HTTP_X_REQUEST_ID"]?
        request_id.gsub(/[^\w\-]/, "")[0,255]
      end
    end

    private def internal_request_id
      SecureRandom.uuid
    end
  end
end
