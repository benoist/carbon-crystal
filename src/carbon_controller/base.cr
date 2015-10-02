require "json"

module CarbonController
  class RenderTemplateEvent < CarbonSupport::Notifications::Event
    def message
      "#{@message} in #{duration_text}"
    end
  end

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
      # @_response || HTTP::Response.new(@_status, @_body, @_headers)
      {@_status, @_headers, CarbonDispatch::BodyProxy.new(@_body) }
    end

    macro render(template = nil, text = nil, json = nil)
      {% if template %}
        # CarbonSupport::Notifier.instance.instrument(CarbonController::RenderTemplateEvent.new("Rendering template {{template.id}}")) do
          @_body = ::Views::Application::{{template.id.capitalize}}.new(controller=self).to_s
        # end
        @_headers["Content-Type"] = "text/html"
        return
      {% end %}

      {% if text %}
        # CarbonSupport::Notifier.instance.instrument(CarbonSupport::Notifications::Event.new("Rendering text")) do
          @_body = {{text}}
        # end
        @_headers["Content-Type"] = "text/plain"
        return
      {% end %}

      {% if json %}
        @_headers["Content-Type"] = "application/json"
        # CarbonSupport::Notifier.instance.instrument(CarbonSupport::Notifications::Event.new("Rendering json")) do
          @_body = {{json}}.to_json
        # end
        return
      {% end %}
    end
  end
end
