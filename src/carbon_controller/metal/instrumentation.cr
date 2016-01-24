{% for key in [:view_runtime, :status, :controller, :action, :params, :format, :method, :path, :filter] %}
  CarbonSupport::Notifications::Payload.define_property({{key}})
{% end %}

module CarbonController
  module Instrumentation
    def process_action(name, block)
      raw_payload = CarbonSupport::Notifications::Payload.new

      raw_payload.controller = self.class.to_s
      raw_payload.action = @_action_name
      raw_payload.method = request.method
      raw_payload.path = (request.path rescue "unknown")
      raw_payload.params = request.params

      CarbonSupport::Notifications.instrument("start_processing.carbon_controller", raw_payload)

      CarbonSupport::Notifications.instrument("process_action.carbon_controller", raw_payload) do |payload|
        begin
          result = super
          payload.status = response.status_code
          result
        ensure
          append_info_to_payload(payload)
        end
      end
    end

    def halted_callback_hook(filter)
      raw_payload = CarbonSupport::Notifications::Payload.new
      raw_payload.filter = filter
      CarbonSupport::Notifications.instrument("halted_callback.carbon_controller", raw_payload)
    end

    def render(*args)
      @view_runtime = cleanup_view_runtime do
        Benchmark.realtime { @render_output = super }
      end
      @render_output
    end

    private def view_runtime
      @view_runtime
    end

    def cleanup_view_runtime
      yield
    end

    protected def append_info_to_payload(payload)
      payload.view_runtime = view_runtime
    end
  end
end
