require "json"

module CarbonController
  class Base
    macro inherited
      include CarbonDispatch::Routing::Routable
    end

    def initialize(@_request)
      @_response = HTTP::Response.new(200)
      @_headers = HTTP::Headers{ "Content-Type" => "text/html" }
      @_body = nil
      @_status = 200
      @_response = nil
    end

    def request
      @_request
    end

    def response
      @_response || HTTP::Response.new(@_status, @_body, @_headers)
    end

    macro render(template = nil, text = nil, json = nil)
      {% if template %}
        @_body = ::Views::Application::{{template.id.capitalize}}.new(controller=self).to_s
        @_headers["Content-Type"] = "text/html"
        return
      {% end %}

      {% if text %}
        @_body = {{text}}
        @_headers["Content-Type"] = "text/plain"
        return
      {% end %}

      {% if json %}
        @_headers["Content-Type"] = "application/json"
        @_body = {{json}}.to_json
        return
      {% end %}
    end
  end
end
