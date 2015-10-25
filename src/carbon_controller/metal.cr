require "./metal/*"

module CarbonController
  class Metal < Abstract
    include CarbonController::Instrumentation
    include CarbonSupport::Callbacks

    macro action(name, request, response)
      proc = ->(controller : {{@type}}) { controller.{{name.id}} }

      {{@type}}.new({{request}}, {{response}}).dispatch(:{{name.id}}, proc)
    end

    def initialize(request, response)
      @_headers = {"Content-Type" => "text/html"}
      @_status = 200
      @_request = request
      @_response = response
      @_routes = nil
      super()
    end

    def dispatch(action, block)
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
