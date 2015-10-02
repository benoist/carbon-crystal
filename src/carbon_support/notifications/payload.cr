module CarbonSupport
  module Notifications
    class Payload
      property :exception
      property :message

      def ==(other : Payload)
        exception == other.exception &&
            message == other.message
      end
    end
  end
end
