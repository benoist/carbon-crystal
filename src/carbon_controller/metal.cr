require "./instrumentation"
module CarbonController
  class Metal < Abstract
    include CarbonController::Instrumentation

    macro action(name, request, response)
      proc = ->(controller : {{@type}}) { controller.{{name.id}} }

      {{@type}}.new.dispatch({{name}}, {{request}}, {{response}}, proc)
    end

    def initialize
      @_headers  = { "Content-Type" => "text/html" }
      @_status   = 200
      @_request  = nil
      @_response = CarbonDispatch::Response.new
      @_routes   = nil
      super
    end

    def dispatch(action, request, response, block)
      @_request  = request
      @_response = response
      process(action, block)
      nil
    end

    def request
      @_request
    end

    def response
      @_response
    end
  end
end
