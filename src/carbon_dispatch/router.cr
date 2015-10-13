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
      action = nil
      routes.each do |route|
        match = route.match(request.path)
        if match.is_a?(Hash(String, String?))
          request.path_params = match
          action = route
          break
        end
      end

      if action
        action.call(request, response)
      else
        response.status = 404
        response.body = "Not Found"
      end
    end

    def self.routes
      @@routes ||= [] of Route
    end

    def self.views
      @@views ||= [] of String
    end

    macro get(path, controller = nil, action = nil)
      class ::Views::{{controller.id.capitalize}}::{{action.id.capitalize}} < CarbonView::Base
        ecr_file "src/views/{{controller.id}}/{{action.id}}.html.ecr"
      end

      CarbonView::Base["{{controller.id.capitalize}}Controller/{{action.id}}"] = ::Views::{{controller.id.capitalize}}::{{action.id.capitalize}}

      self.routes << CarbonDispatch::Route.create({{controller}}, {{action}}, {{path}})
    end
  end
end
