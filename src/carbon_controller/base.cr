require "./metal"

module CarbonController
  class Base < Metal
    def request
      @_request
    end

    def response
      @_response
    end

    def render_template(template)
      response.body = CarbonView::Base["#{self.class.to_s}/#{template}"].new(controller=self).to_s
      response.headers["Content-Type"] = "text/html"
    end

    def render_text(text)
      response.body = text
      response.headers["Content-Type"] = "text/plain"
    end

    def render_json(object)
      response.headers["Content-Type"] = "application/json"
      response.body = object.to_json
    end
  end
end
