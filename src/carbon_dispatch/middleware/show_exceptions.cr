module CarbonDispatch
  class ShowExceptions
    class ExceptionApp
      ECR.def_to_s __DIR__ + "/templates/exception.html.ecr"

      def call(exception, request, response)
        @exception = exception
        @request = request
        @response = response
        response.body = to_s
      end

      def exception
        @exception || raise(ArgumentError.new("No Exception given"))
      end

      def request
        @request || raise(ArgumentError.new("No request given"))
      end

      def response
        @response || raise(ArgumentError.new("No response given"))
      end
    end

    include Middleware

    def initialize(exception_app = nil)
      super()
      @exception_app = exception_app || ExceptionApp.new
    end

    def call(request, response)
      begin
        app.call(request, response)
      rescue e : Exception
        render_exception(e, request, response)
      end
    end

    def render_exception(exception, request, response)
      begin
        @exception_app.call(exception, request, response)
      rescue e : Exception
        response.status_code = 500
        response.headers["Content-Type"] = "text/plain"
        response.body = "500 Internal server error"
      end
    end
  end
end
