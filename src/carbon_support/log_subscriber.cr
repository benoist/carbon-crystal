require "./subscriber"

module CarbonSupport
  class LogSubscriber < Subscriber
    # Embed in a String to clear all previous ANSI sequences.
    CLEAR = "\e[0m"
    BOLD  = "\e[1m"

    # Colors
    BLACK   = "\e[30m"
    RED     = "\e[31m"
    GREEN   = "\e[32m"
    YELLOW  = "\e[33m"
    BLUE    = "\e[34m"
    MAGENTA = "\e[35m"
    CYAN    = "\e[36m"
    WHITE   = "\e[37m"

    def self.logger
      @@logger ||= Carbon.logger
    end

    def self.logger=(logger)
      @@logger = logger
    end

    def self.log_subscribers
      subscribers
    end

    def logger
      LogSubscriber.logger
    end

    def start(name, id, payload)
      super if logger
    end

    def finish(name, id, payload)
      super if logger
    rescue e : Exception
      logger.error "Could not log #{name.inspect} event. #{e.class}: #{e.message} #{e.backtrace}"
    end

    {% for level in ["info", "debug", "warn", "error", "fatal", "unknown"] %}
      protected def {{level.id}}
        logger.{{level.id}}(yield) if logger
      end

      protected def {{level.id}}(progname = nil)
        logger.{{level.id}}(progname) if logger
      end
    {% end %}

    # Set color by using a symbol or one of the defined constants. If a third
    # option is set to +true+, it also adds bold to the string. This is based
    # on the Highline implementation and will automatically append CLEAR to the
    # end of the returned String.
    macro color(text, color, bold = false)
      color = {{@type}}::{{color.id.upcase}}
      bold  = {{bold.id}} ? BOLD : ""
      "#{bold}#{color}{{text.id}}#{CLEAR}"
    end
  end
end
