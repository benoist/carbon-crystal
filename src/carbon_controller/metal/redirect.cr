module CarbonController
  class RedirectBackError < Exception
    DEFAULT_MESSAGE = "No HTTP_REFERER was set in the request to this action, so redirect_to :back could not be called successfully."

    def initialize(message = nil)
      super(message || DEFAULT_MESSAGE)
    end
  end

  module Redirect
    def redirect_to(options = Hash(Symbol, Symbol | String).new, response_status = Hash(Symbol, Symbol).new : Hash(Symbol, Symbol))
      raise CarbonControllerError.new("Cannot redirect to nil!") if options.nil?
      raise CarbonControllerError.new("Cannot redirect to a parameter hash!") if options.is_a?(HTTP::Params)

      response.status_code = _extract_redirect_to_status(options, response_status)
      response.location = _compute_redirect_to_location(request, options)
    end

    private def _compute_redirect_to_location(request, options) # :nodoc:
      # First case:
      #
      # The scheme name consist of a letter followed by any combination of
      # letters, digits, and the plus ("+"), period ("."), or hyphen ("-")
      # characters; and is terminated by a colon (":").
      # See http://tools.ietf.org/html/rfc3986#section-3.1
      # The protocol relative scheme starts with a double slash "//".
      case options
      when /\A([a-z][a-z\d\-+\.]*:|\/\/).*/i
        options
      when String
        request.protocol + request.host_with_port + options
      when :back
        referer = request.headers["Referer"]?

        if referer && referer != ""
          referer
        else
          raise RedirectBackError.new
        end
      else
        # TODO: Use this once #url_for is implemented
        # url_for(options)
      end.to_s.delete("\0\r\n")
    end

    private def _extract_redirect_to_status(options, response_status)
      if options.is_a?(Hash) && options.has_key?(:status)
        HTTPUtil.status_code(options.delete(:status))
      elsif response_status.has_key?(:status)
        HTTPUtil.status_code(response_status[:status])
      else
        302
      end
    end
  end
end
