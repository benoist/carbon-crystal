module CarbonController
  class LogSubscriber < CarbonSupport::LogSubscriber
    def start_processing(event)
      payload = event.payload

      info "Processing by #{payload.controller}##{payload.action} as HTML"
      info "  Parameters: #{payload.params}"
    end

    def process_action(event)
      info do
        payload = event.payload

        status = payload.status
        if status.nil? && payload.exception
          status = 500
        end
        "Completed #{status} in #{event.duration_text}"
      end
    end

    attach_to :carbon_controller
  end
end
