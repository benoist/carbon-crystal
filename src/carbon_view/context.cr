module CarbonView
  module Context
    property :output_buffer
    property :view_flow

    def _prepare_context
      @view_flow = OutputFlow.new
      @output_buffer = nil
      @virtual_path = nil
    end
  end
end
