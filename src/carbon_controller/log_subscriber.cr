module CarbonController
  class LogSubscriber < CarbonSupport::LogSubscriber
    def start_processing(event)
        payload = event.payload

        info "Processing by #{payload.controller}##{payload.action} as HTML"
    end

    def process_action(event)
      info do
        payload = event.payload

        status = payload.status
        if status.nil? && payload.exception
          status = payload.exception.class.to_s
        end
        "Completed #{status} in #{event.duration_text}"
      end
    end
    attach_to :carbon_controller
  end
end
