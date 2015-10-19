module CarbonController
  class Abstract
    def process_action(name, block)
      block.call(self)
    end

    def process(name, block)
      @_action_name = name
      @_response_body = nil
      process_action(name, block)
    end
  end
end
