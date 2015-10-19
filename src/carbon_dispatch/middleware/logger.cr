module CarbonDispatch
  class Logger < CarbonSupport::LogSubscriber
    include Middleware

    def call(request, response)
      @start = Time.now

      if Carbon.env.development?
        logger.debug ""
        logger.debug ""
      end

      instrumenter = CarbonSupport::Notifications.instrumenter
      instrumenter.start "request.action_dispatch", CarbonSupport::Notifications::Payload.new
      logger.info { started_request_message(request) }
      app.call(request, response)

      response.register_callback { instrument_finish(request) }
    rescue e : Exception
      instrument_finish(request)
      raise e
    end

    # Started GET "/session/new" for 127.0.0.1 at 2012-09-26 14:51:42 -0700
    def started_request_message(request)
      "Started %s \"%s\" for %s at %s" % [
        request.method,
        request.path,
        request.ip,
        Time.now.to_s,
      ]
    end

    def instrument_finish(request)
      instrumenter = CarbonSupport::Notifications.instrumenter
      instrumenter.finish "request.action_dispatch", CarbonSupport::Notifications::Payload.new
    end

    def logger
      Carbon.logger
    end
  end
end
