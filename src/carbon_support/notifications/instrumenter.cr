module CarbonSupport
  module Notifications
    class Instrumenter
      getter id : String

      def initialize(@notifier : Fanout)
        @id = unique_id
      end

      # Instrument the given block by measuring the time taken to execute it
      # and publish it. Notice that events get sent even if an error occurs
      # in the passed-in block.
      def instrument(name, payload = Payload.new)
        start name, payload
        begin
          yield payload
        rescue e : Exception
          payload.exception = [e.class.name, e.message]
          raise e
        ensure
          finish name, payload
        end
      end

      # Send a start notification with +name+ and +payload+.
      def start(name, payload)
        @notifier.start name, @id, payload
      end

      # Send a finish notification with +name+ and +payload+.
      def finish(name, payload)
        @notifier.finish name, @id, payload
      end

      private def unique_id
        SecureRandom.hex(10)
      end
    end
  end
end
