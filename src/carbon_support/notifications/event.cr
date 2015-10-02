module CarbonSupport
  module Notifications
    class Event
      property :name
      property :start
      property :end
      property :message
      property :children
      property :payload
      property :object

      def initialize(name, start, ending, transaction_id, payload)
        @name           = name
        @payload        = payload
        @time           = start
        @transaction_id = transaction_id
        @end            = ending
        @children       = [] of Event
        @duration       = nil
      end

      def duration
        start  = @start || Time.now
        finish = @finish || Time.now

        finish - start
      end

      def <<(event)
        @children << event
      end

      def parent_of?(event)
        @children.include? event
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
