require "./metal/*"

module CarbonController
  class Metal < Abstract
    macro action(name, request, response)
      proc = ->(controller : {{@type}}) { controller.{{name.id}} }

      {{@type}}.new({{request}}, {{response}}).dispatch(:{{name.id}}, proc)
    end

    def initialize(@_request : CarbonDispatch::Request, @_response : CarbonDispatch::Response)
      @_headers = {"Content-Type" => "text/html"}
      @_status = 200
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
