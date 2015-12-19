require "./metal"

module CarbonController
  class Base < Metal
    delegate :params, :request

    def self.layout(layout = nil)
      @@layout ||= layout
    end

    include Head
    include Redirect
    include Session
    include Cookies
    include Flash
    include CarbonController::Callbacks
    include Instrumentation

    def request
      @_request
    end

    def response
      @_response
    end

    macro render_template(template)
      layout = CarbonView::Base.layouts["Layouts::{{ @type.id.gsub(/Controller\+?/, "") }}"].new(controller = self)
      view = CarbonViews::{{ @type.id.gsub(/Controller\+?/, "") }}::{{template.camelcase.id}}.new(controller = self)

      response.body = layout.render(view)
      response.headers["Content-Type"] = "text/html"
    end

    def render_text(text)
      response.body = text
      response.headers["Content-Type"] = "text/plain"
    end

    def render_json(object)
      response.body = object.to_json
      response.headers["Content-Type"] = "application/json"
    end
  end
end
