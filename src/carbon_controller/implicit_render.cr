module CarbonController
  module ImplicitRender
    def process_action(name, block)
      super
      unless response.body
        render_template name
      end
    end
  end
end
