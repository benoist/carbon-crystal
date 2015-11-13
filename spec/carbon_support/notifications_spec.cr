require "../spec_helper"

module CarbonSupportTest
  describe CarbonSupport::Notifications do
    it "tests subscribed" do
      name = "foo"
      name2 = name * 2
      expected = [name, name]

      events = [] of String
      callback = ->(event : CarbonSupport::Notifications::Event) { events << event.name }
      CarbonSupport::Notifications.subscribed(callback, name) do
        CarbonSupport::Notifications.instrument(name)
        CarbonSupport::Notifications.instrument(name2)
        CarbonSupport::Notifications.instrument(name)
      end
      events.should eq expected

      CarbonSupport::Notifications.instrument(name)
      events.should eq expected
    end

    it "removes a subscription when unsubscribing" do
      notifier = CarbonSupport::Notifications::Fanout.new
      events = [] of String
      subscription = notifier.subscribe do |event|
        events << event.name
      end
      notifier.publish "name", Time.now, Time.now, "id", CarbonSupport::Notifications::Payload.new
      notifier.wait
      events.should eq ["name"]
      notifier.unsubscribe(subscription)
      notifier.publish "name", Time.now, Time.now, "id", CarbonSupport::Notifications::Payload.new
      notifier.wait
      events.should eq ["name"]
    end

    it "removes a subscription when unsubscribing with name" do
      notifier = CarbonSupport::Notifications::Fanout.new
      named_events = [] of String
      subscription = notifier.subscribe "named.subscription" do |event|
        named_events << event.name
      end
      notifier.publish "named.subscription", Time.now, Time.now, "id", CarbonSupport::Notifications::Payload.new
      notifier.wait
      named_events.should eq ["named.subscription"]
      notifier.unsubscribe("named.subscription")
      notifier.publish "named.subscription", Time.now, Time.now, "id", CarbonSupport::Notifications::Payload.new
      notifier.wait
      named_events.should eq ["named.subscription"]
    end

    it "leaves the other subscriptions when unsubscribing by name " do
      notifier = CarbonSupport::Notifications::Fanout.new
      events = [] of String
      named_events = [] of String
      subscription = notifier.subscribe "named.subscription" do |event|
        named_events << event.name
      end
      subscription = notifier.subscribe do |event|
        events << event.name
      end
      notifier.publish "named.subscription", Time.now, Time.now, "id", CarbonSupport::Notifications::Payload.new
      notifier.wait
      events.should eq ["named.subscription"]
      notifier.unsubscribe("named.subscription")
      notifier.publish "named.subscription", Time.now, Time.now, "id", CarbonSupport::Notifications::Payload.new
      notifier.wait
      events.should eq ["named.subscription", "named.subscription"]
    end

    it "returns the block result" do
      CarbonSupport::Notifications.instrument("name") { 1 + 1 }.should eq 2
    end

    it "exposes an id method" do
      CarbonSupport::Notifications.instrumenter.id.size.should eq 20
    end

    it "allows nested events" do
      CarbonSupport::Notifications.notifier = CarbonSupport::Notifications::Fanout.new
      events = [] of String
      CarbonSupport::Notifications.notifier.subscribe do |event|
        events << event.name
      end

      CarbonSupport::Notifications.instrument("outer") do
        CarbonSupport::Notifications.instrument("inner") do
          1 + 1
        end
        events.size.should eq 1
        events.first.should eq "inner"
      end

      events.size.should eq 2
      events.last.should eq "outer"
    end

    it "publishes when exceptions are raised" do
      CarbonSupport::Notifications.notifier = CarbonSupport::Notifications::Fanout.new
      events = [] of String
      CarbonSupport::Notifications.notifier.subscribe do |event|
        events << event.name
      end

      begin
        CarbonSupport::Notifications.instrument("raises") do
          raise "FAIL"
        end
      rescue e : Exception
        e.message.should eq "FAIL"
      end

      events.size.should eq 1
    end

    it "publishes when instrumented without a block" do
      CarbonSupport::Notifications.notifier = CarbonSupport::Notifications::Fanout.new
      events = [] of String
      CarbonSupport::Notifications.notifier.subscribe do |event|
        events << event.name
      end

      CarbonSupport::Notifications.instrument("no block")

      events.size.should eq 1
      events.first.should eq "no block"
    end

    it "publishes events with details" do
      CarbonSupport::Notifications.notifier = CarbonSupport::Notifications::Fanout.new
      events = [] of CarbonSupport::Notifications::Event
      CarbonSupport::Notifications.notifier.subscribe do |event|
        events << event
      end

      CarbonSupport::Notifications.instrument("outer", CarbonSupport::Notifications::Payload.new.tap { |p| p.message = "test" }) do
        CarbonSupport::Notifications.instrument("inner")
      end

      events.first.name.should eq "inner"
      events.last.payload.message.should eq "test"
    end
  end
end
