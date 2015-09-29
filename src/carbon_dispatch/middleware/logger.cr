module CarbonDispatch
  class Logger < CarbonSupport::Subscriber
    include Middleware

    def initialize
      super
      CarbonSupport::Notifier.instance.subscribe(self)
    end

    def start(event : CarbonSupport::Notifications::Event)
      logger.info event.message
    end

    def finish(event : CarbonSupport::Notifications::Event)
      case event.object
        when Environment
          logger.info "Completed in #{event.duration_text}"
      end
    end

    def call(env)
      @start = Time.now

      if Carbon.env.development?
        logger.debug ""
        logger.debug ""
      end

      instrumenter = CarbonSupport::Notifier.instrumenter
      instrumenter.start CarbonSupport::Notifications::Event.new(started_request_message(env))
      status, headers, body = app.call(env)

      body = BodyProxy.new(body) { instrument_finish(env) }

      {status, headers, body}
    rescue e : Exception
      instrument_finish(env)
      raise e
    end

    # Started GET "/session/new" for 127.0.0.1 at 2012-09-26 14:51:42 -0700
    def started_request_message(env)
      "Started %s \"%s\" for %s at %s" % [
          env.request.method,
          env.request.path,
          env.ip,
          Time.now.to_s]
    end

    def instrument_finish(env)
      instrumenter = CarbonSupport::Notifier.instrumenter
      instrumenter.finish(CarbonSupport::Notifications::Event.new(env))
    end

    def logger
      Carbon.logger
    end
  end
end
