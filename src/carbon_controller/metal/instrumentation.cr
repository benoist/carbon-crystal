{% for key in [:view_runtime, :status, :controller, :action, :params, :format, :method, :path] %}
  CarbonSupport::Notifications::Payload.define_property({{key}})
{% end %}

module CarbonController
  module Instrumentation
    macro included
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
            result = previous_def
            payload.status = response.status
            result
          ensure
            append_info_to_payload(payload)
          end
        end
      end
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
