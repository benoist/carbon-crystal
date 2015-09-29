require "../carbon_support/notifications/event"

module CarbonSupport
  class Subscriber
    def initialize
      @timestack = Hash(Fiber, Array(Time)).new { |h,k| h[k] = [] of Time }
    end

    def initialize(&@block : CarbonSupport::Notifications::Event -> Void)
      @timestack = Hash(Fiber, Array(Time)).new { |h,k| h[k] = [] of Time }
    end

    def start(event : CarbonSupport::Notifications::Event)
    end

    def receive_start(event : CarbonSupport::Notifications::Event)
      @timestack[Fiber.current] << Time.now
      start(event)
    end

    def finish(event : CarbonSupport::Notifications::Event)
    end

    def receive_finish(event : CarbonSupport::Notifications::Event)
      event.start = @timestack[Fiber.current].pop
      @timestack.delete(Fiber.current) if @timestack[Fiber.current].size == 0
      event.finish = Time.now

      finish(event)
      @block.try &.call(event)
    end
  end
end
