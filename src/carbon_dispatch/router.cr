module CarbonDispatch
  class Router
    include Middleware

    macro inherited
      begin
        Carbon.application.router = new(self.routes)
      rescue
      end
    end

    getter :routes

    def initialize(@routes)
    end

    def call(request, response)
      action = routes[request.path]?

      if action
        action.call(request, response)
      else
        response.status = 404
        response.body = "Not Found"
      end
    end

    def self.routes
      @@routes ||= {} of String => CarbonDispatch::Request, CarbonDispatch::Response -> Nil
    end

    def self.views
      @@views ||= [] of String
    end

    macro get(path, controller = nil, action = nil)
      class ::Views::{{controller.id.capitalize}}::{{action.id.capitalize}} < CarbonView::Base
        ecr_file "src/views/{{controller.id}}/{{action.id}}.html.ecr"
      end

      CarbonView::Base["{{controller.id.capitalize}}Controller/{{action.id}}"] = ::Views::{{controller.id.capitalize}}::{{action.id.capitalize}}

      self.routes[{{path}}] = ->(request : CarbonDispatch::Request, response : CarbonDispatch::Response) {
        {{controller.id.capitalize}}Controller.action({{action}}, request, response)
      }
    end
  end
end
