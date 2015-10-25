require "../spec_helper"

module CarbonSupportTest
  class NormalCallbackTest
    include CarbonSupport::Callbacks

    getter :callstack
    define_callbacks :test

    set_callback :test, :before, :before1
    set_callback :test, :around, :test_around
    set_callback :test, :before, :before2
    set_callback :test, :after, :after1
    set_callback :test, :around, :test_around2
    set_callback :test, :before, :before3
    set_callback :test, :after, :after2

    def initialize
      @callstack = [] of String
    end

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

  describe CarbonSupport::Callbacks do
    context "normal callbacks" do
      object = NormalCallbackTest.new
      object.test.should eq "result"
      object.callstack.should eq [
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
    end
  end
end
