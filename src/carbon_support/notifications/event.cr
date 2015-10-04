module CarbonSupport
  module Notifications
    class Event
      property :name
      property :start
      property :end
      property :transaction_id
      property :children
      property :payload
      property :object

      def initialize(name : String, start : Time, ending : Time, transaction_id : String, payload : Payload)
        @name           = name
        @payload        = payload
        @start          = start
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

      def <<(event : Event)
        @children << event
      end

      def parent_of?(event : Event)
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

      def ==(other)
        name == other.name &&
            payload == other.payload &&
            start == other.start &&
            self.end == other.end &&
            transaction_id == other.transaction_id
      end
    end
  end
end
