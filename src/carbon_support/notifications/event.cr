module CarbonSupport
  module Notifications
    class Event
      property :start
      property :finish
      property :message
      property :object

      def initialize

      end

      def initialize(@object)

      end

      def initialize(@message : String)
      end

      def duration
        start = @start || Time.now
        finish = @finish || Time.now

        finish - start
      end

      def duration_text
        minutes = duration.total_minutes
        return "#{minutes.round(2)}m" if minutes >= 1

        seconds = duration.total_seconds
        return "#{seconds.round(2)}s" if seconds >= 1

        millis = duration.total_milliseconds
        return "#{millis.round(2)}ms" if millis >= 1

        "#{(millis * 1000).round(2)}µs"
      end
    end
  end
end
