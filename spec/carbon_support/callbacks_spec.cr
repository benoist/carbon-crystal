require "../spec_helper"

module CarbonSupportTest
  class Base
    include CarbonSupport::Callbacks
    getter :callstack

    def initialize
      @callstack = [] of String
    end

    define_callbacks :test

    set_callback :test, :before, :inherited_before

    def inherited_before
      callstack << "inherited before"
    end
  end

  class NormalCallbackTest < Base
    set_callback :test, :before, :before1
    set_callback :test, :around, :test_around
    set_callback :test, :before, :before2
    set_callback :test, :after, :after1
    set_callback :test, :around, :test_around2
    set_callback :test, :before, :before3
    set_callback :test, :after, :after2

    def test
      run_callbacks :test do
        callstack << "test"
        "result"
      end
    end

    def test_around
      callstack << "around1a"
      yield
      callstack << "around1b"
    end

    def test_around2
      callstack << "around2a"
      yield
      callstack << "around2b"
    end

    def before1
      callstack << "before 1"
    end

    def before2
      callstack << "before 2"
    end

    def before3
      callstack << "before 3"
    end

    def after1
      callstack << "after 1"
    end

    def after2
      callstack << "after 2"
    end
  end

  class InheritedCallbackTest < NormalCallbackTest
  end

  class HaltingCallbackTest
    include CarbonSupport::Callbacks
    getter :callstack

    def initialize
      @callstack = [] of String
    end

    class CallStackTerminator
      def terminate?(target, result)
        target.callstack.size == 1 if target.is_a?(HaltingCallbackTest)
      end
    end

    define_callbacks(:test)
    define_callbacks(:test_with_terminator, CallbackChain::Options.new(
      terminator: CallStackTerminator.new,
      skip_after_callbacks_if_terminated: true))
    set_callback :test, :before, :before1
    set_callback :test, :before, :before2
    set_callback :test_with_terminator, :before, :before1
    set_callback :test_with_terminator, :before, :before2

    def halted_callback_hook(filter)
      callstack << "halted #{filter}"
    end

    def test
      run_callbacks :test do
        callstack << "test"
        "result"
      end
    end

    def test_with_terminator
      run_callbacks :test_with_terminator do
        callstack << "test"
        "result"
      end
    end

    def before1
      callstack << "before 1"
    end

    def before2
      callstack << "before 2"
      false
    end
  end

  class OtherTerminatorTest < Base
    class DelegateTerminator
      def terminate?(target, result)
        target.terminate? if target.is_a?(OtherTerminatorTest)
      end
    end

    def terminate?
      true
    end

    define_callbacks(:test_with_terminator, CallbackChain::Options.new(
      terminator: DelegateTerminator.new,
      skip_after_callbacks_if_terminated: true))
    set_callback :test_with_terminator, :before, :before1
    set_callback :test_with_terminator, :before, :before2

    def test_with_terminator
      run_callbacks :test_with_terminator do
        callstack << "test"
        "result"
      end
    end

    def halted_callback_hook(filter)
      callstack << "halted #{filter}"
    end

    def before1
      callstack << "before 1"
    end

    def before2
      callstack << "before 2"
      false
    end
  end

  describe CarbonSupport::Callbacks do
    it "normal callbacks" do
      object = NormalCallbackTest.new
      result = object.test
      object.callstack.should eq [
        "inherited before",
        "before 1",
        "around1a",
        "before 2",
        "around2a",
        "before 3",
        "test",
        "after 2",
        "around2b",
        "after 1",
        "around1b",
      ]
      result.should eq "result"
    end

    it "inherited callbacks" do
      object = InheritedCallbackTest.new
      result = object.test
      object.callstack.should eq [
        "inherited before",
        "before 1",
        "around1a",
        "before 2",
        "around2a",
        "before 3",
        "test",
        "after 2",
        "around2b",
        "after 1",
        "around1b",
      ]
      result.should eq "result"
    end

    it "halting callbacks" do
      object = HaltingCallbackTest.new
      result = object.test
      object.callstack.should eq [
        "before 1",
        "before 2",
        "halted before2",
      ]
      result.should eq false
    end

    it "halting callbacks" do
      object = HaltingCallbackTest.new
      result = object.test_with_terminator
      object.callstack.should eq [
        "before 1",
        "halted before1",
      ]
      result.should eq false
    end

    it "other terminator callbacks" do
      object = OtherTerminatorTest.new
      result = object.test_with_terminator
      object.callstack.should eq [
        "before 1",
        "halted before1",
      ]
      result.should eq false
    end
  end
end
