module CarbonSupport
  module Notifications
    class Event
      property :start
      property :finish

      def duration
        start = @start || Time.now
        finish = @finish || Time.now

        finish - start
      end
    end
  end
end
