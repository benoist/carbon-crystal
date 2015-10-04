require "../spec_helper"

module CarbonSupportTest
  describe CarbonSupport::Notifications do
    it "tests subscribed" do
      name     = "foo"
      name2    = name * 2
      expected = [name, name]

      events   = [] of String
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
      events   = [] of String
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
      named_events   = [] of String
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
      events   = [] of String
      named_events   = [] of String
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
  end
end
#
#   class TestSubscriber
#     attr_reader :starts, :finishes, :publishes
#
#     def initialize
#       @starts    = []
#       @finishes  = []
#       @publishes = []
#     end
#
#     def start(*args);  @starts << args; end
#     def finish(*args); @finishes << args; end
#     def publish(*args); @publishes << args; end
#   end
#
#   class SyncPubSubTest < TestCase
#     def test_events_are_published_to_a_listener
#       @notifier.publish :foo
#       @notifier.wait
#       assert_equal [[:foo]], @events
#     end
#
#     def test_publishing_multiple_times_works
#       @notifier.publish :foo
#       @notifier.publish :foo
#       @notifier.wait
#       assert_equal [[:foo], [:foo]], @events
#     end
#
#     def test_publishing_after_a_new_subscribe_works
#       @notifier.publish :foo
#       @notifier.publish :foo
#
#       @notifier.subscribe("not_existent") do |*args|
#         @events << ActiveSupport::Notifications::Event.new(*args)
#       end
#
#       @notifier.publish :foo
#       @notifier.publish :foo
#       @notifier.wait
#
#       assert_equal [[:foo]] * 4, @events
#     end
#
#     def test_log_subscriber_with_string
#       events = []
#       @notifier.subscribe('1') { |*args| events << args }
#
#       @notifier.publish '1'
#       @notifier.publish '1.a'
#       @notifier.publish 'a.1'
#       @notifier.wait
#
#       assert_equal [['1']], events
#     end
#
#     def test_log_subscriber_with_pattern
#       events = []
#       @notifier.subscribe(/\d/) { |*args| events << args }
#
#       @notifier.publish '1'
#       @notifier.publish 'a.1'
#       @notifier.publish '1.a'
#       @notifier.wait
#
#       assert_equal [['1'], ['a.1'], ['1.a']], events
#     end
#
#     def test_multiple_log_subscribers
#       @another = []
#       @notifier.subscribe { |*args| @another << args }
#       @notifier.publish :foo
#       @notifier.wait
#
#       assert_equal [[:foo]], @events
#       assert_equal [[:foo]], @another
#     end
#
#     def test_publish_with_subscriber
#       subscriber = TestSubscriber.new
#       @notifier.subscribe nil, subscriber
#       @notifier.publish :foo
#
#       assert_equal [[:foo]], subscriber.publishes
#     end
#
#     private
#       def event(*args)
#         args
#       end
#   end
#
#   class InstrumentationTest < TestCase
#     delegate :instrument, :to => ActiveSupport::Notifications
#
#     def test_instrument_returns_block_result
#       assert_equal 2, instrument(:awesome) { 1 + 1 }
#     end
#
#     def test_instrument_yields_the_payload_for_further_modification
#       assert_equal 2, instrument(:awesome) { |p| p[:result] = 1 + 1 }
#       assert_equal 1, @events.size
#       assert_equal :awesome, @events.first.name
#       assert_equal Hash[:result => 2], @events.first.payload
#     end
#
#     def test_instrumenter_exposes_its_id
#       assert_equal 20, ActiveSupport::Notifications.instrumenter.id.size
#     end
#
#     def test_nested_events_can_be_instrumented
#       instrument(:awesome, :payload => "notifications") do
#         instrument(:wot, :payload => "child") do
#           1 + 1
#         end
#
#         assert_equal 1, @events.size
#         assert_equal :wot, @events.first.name
#         assert_equal Hash[:payload => "child"], @events.first.payload
#       end
#
#       assert_equal 2, @events.size
#       assert_equal :awesome, @events.last.name
#       assert_equal Hash[:payload => "notifications"], @events.last.payload
#     end
#
#     def test_instrument_publishes_when_exception_is_raised
#       begin
#         instrument(:awesome, :payload => "notifications") do
#           raise "FAIL"
#         end
#       rescue RuntimeError => e
#         assert_equal "FAIL", e.message
#       end
#
#       assert_equal 1, @events.size
#       assert_equal Hash[:payload => "notifications",
#         :exception => ["RuntimeError", "FAIL"]], @events.last.payload
#     end
#
#     def test_event_is_pushed_even_without_block
#       instrument(:awesome, :payload => "notifications")
#       assert_equal 1, @events.size
#       assert_equal :awesome, @events.last.name
#       assert_equal Hash[:payload => "notifications"], @events.last.payload
#     end
#   end
#
#   class EventTest < TestCase
#     def test_events_are_initialized_with_details
#       time = Time.now
#       event = event(:foo, time, time + 0.01, random_id, {})
#
#       assert_equal    :foo, event.name
#       assert_equal    time, event.time
#       assert_in_delta 10.0, event.duration, 0.00001
#     end
#
#     def test_events_consumes_information_given_as_payload
#       event = event(:foo, Time.now, Time.now + 1, random_id, :payload => :bar)
#       assert_equal Hash[:payload => :bar], event.payload
#     end
#
#     def test_event_is_parent_based_on_children
#       time = Time.utc(2009, 01, 01, 0, 0, 1)
#
#       parent    = event(:foo, Time.utc(2009), Time.utc(2009) + 100, random_id, {})
#       child     = event(:foo, time, time + 10, random_id, {})
#       not_child = event(:foo, time, time + 100, random_id, {})
#
#       parent.children << child
#
#       assert parent.parent_of?(child)
#       assert !child.parent_of?(parent)
#       assert !parent.parent_of?(not_child)
#       assert !not_child.parent_of?(parent)
#     end
#
#     protected
#       def random_id
#         @random_id ||= SecureRandom.hex(10)
#       end
#   end
# end
