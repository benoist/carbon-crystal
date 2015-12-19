module CarbonController
  module Callbacks
    class ResponseTerminator
      def terminate?(target, result)
        target.response.body.present? if target.is_a?(CarbonController::Base)
      end
    end

    macro included
      include CarbonSupport::Callbacks
      define_callbacks(:process_action, CallbackChain::Options.new(
                                          terminator: ResponseTerminator.new,
                                          skip_after_callbacks_if_terminated: true)
      )
    end

    def process_action(name, block)
      run_callbacks(:process_action) do
        super
        true
      end
    end

    macro before_action(name)
      set_callback :process_action, :before, {{name}}
    end

    macro after_action(name)
      set_callback :process_action, :after, {{name}}
    end

    macro around_action(name)
      set_callback :process_action, :around, {{name}}
    end
  end
end
