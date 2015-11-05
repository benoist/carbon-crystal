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
        match = route.match(request.method, request.path)
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

    macro action(methods, path, controller = nil, action = nil)
      class ::Views::{{controller.id.camelcase}}::{{action.id.camelcase}} < CarbonView::Base
        ecr_file "src/views/{{controller.id}}/{{action.id}}.html.ecr"
      end

      CarbonView::Base["{{controller.id.camelcase}}Controller/{{action.id}}"] = ::Views::{{controller.id.camelcase}}::{{action.id.camelcase}}

      self.routes << CarbonDispatch::Route.create({{controller}}, {{action}}, {{methods}}, {{path}})
    end

    macro get(path, controller = nil, action = nil)
      action(["GET"], {{path}}, {{controller}}, {{action}})
    end

    macro post(path, controller = nil, action = nil)
      action(["POST"], {{path}}, {{controller}}, {{action}})
    end

    macro put(path, controller = nil, action = nil)
      action(["PUT"], {{path}}, {{controller}}, {{action}})
    end

    macro patch(path, controller = nil, action = nil)
      action(["PATCH"], {{path}}, {{controller}}, {{action}})
    end

    macro delete(path, controller = nil, action = nil)
      action(["DELETE"], {{path}}, {{controller}}, {{action}})
    end

    macro resources(resource, only = nil, except = nil)
      {% methods = [:index, :new, :create, :show, :edit, :update, :destroy] %}

      {% if only %}
        {% for action in only %}
          resource_action({{resource}}, {{action}})
        {% end %}
      {% elsif except %}
        {% for action in methods %}
          {% should_include = true %}
          {% for except_action in except %}
            {% if except_action == action %}
              {% should_include = false %}
            {% end %}
          {% end %}
          {% if should_include %}
            resource_action({{resource}}, {{action}})
          {% end %}
        {% end %}
      {% else %}
        {% for action in methods %}
          resource_action({{resource}}, {{action}})
        {% end %}
      {% end %}
    end

    macro resource_action(resource, action)
      {% if action == :index %}
        get("/{{resource.id}}", {{resource.id}}, "index")
      {% elsif action == :show %}
        get("/{{resource.id}}/:id", {{resource.id}}, "show")
      {% elsif action == :new %}
        get("/{{resource.id}}/new", {{resource.id}}, "new")
      {% elsif action == :edit %}
        get("/{{resource.id}}/:id/edit", {{resource.id}}, "edit")
      {% elsif action == :create %}
        post("/{{resource.id}}", {{resource.id}}, "create")
      {% elsif action == :update %}
        action(["PATCH", "PUT"], "/{{resource.id}}/:id", {{resource.id}}, "update")
      {% elsif action == :destroy %}
        delete("/{{resource.id}}/:id", {{resource.id}}, "destroy")
      {% end %}
    end
  end
end
