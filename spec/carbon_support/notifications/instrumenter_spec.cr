require "../../spec_helper"

module CarbonSupportTest
  include CarbonSupport::Notifications

  class TestNotifier
    getter :starts, :finishes

    def initialize
      @starts = [] of {String, String, CarbonSupport::Notifications::Payload}
      @finishes = [] of {String, String, CarbonSupport::Notifications::Payload}
    end

    def start(*args)
      @starts << args
    end

    def finish(*args)
      @finishes << args
    end
  end

  describe Instrumenter do
    it "calls the block" do
      notifier = TestNotifier.new
      instrumenter = Instrumenter.new notifier
      payload = Payload.new

      called = false
      instrumenter.instrument("foo", payload) {
        called = true
      }

      called.should be_truthy
    end

    it "yield the payload" do
      notifier = TestNotifier.new
      instrumenter = Instrumenter.new notifier
      instrumenter.instrument("awesome") { |p| p.message = "test" }.should eq "test"
      notifier.finishes.size.should eq 1
      name, _, payload = notifier.finishes.first
      name.should eq "awesome"
      payload.message.should eq "test"
    end

    it "tests start" do
      notifier = TestNotifier.new
      instrumenter = Instrumenter.new notifier
      payload = Payload.new

      instrumenter.start("foo", payload)

      notifier.starts.should eq [{"foo", instrumenter.id, payload}]
      notifier.finishes.empty?.should be_truthy
    end

    it "tests finish" do
      notifier = TestNotifier.new
      instrumenter = Instrumenter.new notifier
      payload = Payload.new
      instrumenter.finish("foo", payload)
      notifier.finishes.should eq [{"foo", instrumenter.id, payload}]
      notifier.starts.empty?.should be_truthy
    end
  end
end
