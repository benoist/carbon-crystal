module CarbonDispatch
  class Logger < Middleware
    def call(env)
      @start = Time.now

      if Carbon.env.development?
        logger.debug ""
        logger.debug ""
      end

      logger.info started_request_message(env)
      status, headers, body = @app.call(env)

      body = BodyProxy.new(body) { logger.info finish(env) }

      {status, headers, body}
    rescue e : Exception
      logger.info finish(env)
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

    def finish(env)
      start = @start
      if start
        elapsed = Time.now - start
        elapsed_text = elapsed_text(elapsed)
        "Completed in #{elapsed_text}"
      end
    end

    def logger
      Carbon.logger
    end

    private def elapsed_text(elapsed)
      minutes = elapsed.total_minutes
      return "#{minutes.round(2)}m" if minutes >= 1

      seconds = elapsed.total_seconds
      return "#{seconds.round(2)}s" if seconds >= 1

      millis = elapsed.total_milliseconds
      return "#{millis.round(2)}ms" if millis >= 1

      "#{(millis * 1000).round(2)}µs"
    end
  end
end
