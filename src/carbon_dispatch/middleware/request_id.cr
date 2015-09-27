module CarbonDispatch
  class RequestId < Middleware
    def call(env)
      env.request_id = external_request_id(env) || internal_request_id
      status, headers, body = @app.call(env)
      headers["X-Request-Id"] = env.request_id.to_s

      {status, headers, body }
    end

    private def external_request_id(env)
      if request_id = env["HTTP_X_REQUEST_ID"]?
        request_id.gsub(/[^\w\-]/, "")[0,255]
      end
    end

    private def internal_request_id
      SecureRandom.uuid
    end
  end
end
