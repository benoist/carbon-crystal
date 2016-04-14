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

    def response : CarbonDispatch::Response
      @_response
    end

    macro render_template(template, status = 200)
      layout = CarbonView::Base.layouts["Layouts::{{ @type.id.gsub(/Controller\+?/, "") }}"].new(controller = self)
      view = CarbonViews::{{ @type.id.gsub(/Controller\+?/, "") }}::{{template.camelcase.id}}.new(controller = self)

      response.status_code = status
      response.body = layout.render(view)
      response.headers["Content-Type"] = "text/html"
    end

    def render_text(text, status = 200)
      response.status_code = status
      response.body = text
      response.headers["Content-Type"] = "text/plain"
    end

    def render_json(object, status = 200)
      response.status_code = status
      response.body = object.to_json
      response.headers["Content-Type"] = "application/json"
    end
  end
end
