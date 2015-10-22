require "./metal"

module CarbonController
  class Base < Metal
    delegate :params, :request

    def request
      @_request
    end

    def response
      @_response
    end

    def render_template(template)
      response.body = CarbonView::Base["#{self.class.to_s}/#{template}"].new(controller = self).to_s
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
