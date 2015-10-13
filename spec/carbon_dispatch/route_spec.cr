require "../spec_helper"

module CarbonDispatchTest
  extend self
  def route(controller, action, path, app = app)
    CarbonDispatch::Route.new(controller, action, path, app)
  end

  def app
    ->(request : CarbonDispatch::Request, response : CarbonDispatch::Response) {}
  end

  describe CarbonDispatch::Route do

    context "pattern" do
      it "matches normal string" do
        route("TestController", "index", "/").match("/").should be_truthy
        route("TestController", "index", "/foo").match("/foo").should be_truthy
        route("TestController", "index", "/foo").match("/").should be_falsey
      end

      it "matches with named_params" do
        route("TestController", "index", "/base/:id").match("/base/1").should be_truthy
        route("TestController", "index", "/base/:id").match("/base/1/").should be_truthy
        route("TestController", "index", "/base/:id").match("/base/1/foo").should be_falsey
      end

      it "matches with optional params" do
        route("TestController", "index", "/base(:option)").match("/base").should be_truthy
        route("TestController", "index", "/base(:option)").match("/base1").should be_truthy
        route("TestController", "index", "/base(:option)").match("/base/a").should be_falsey
        route("TestController", "index", "/base(/:option)").match("/base/1").should be_truthy
        route("TestController", "index", "/base(/:option/fixed)").match("/base/1").should be_falsey
        route("TestController", "index", "/base(/:option/fixed)").match("/base/12/fixed").should be_truthy
      end

      it "matches with slugged param" do
        route("TestController", "index", "/base/*slug").match("/base/foo").should be_truthy
        route("TestController", "index", "/base/*slug").match("/base/foo/bar").should be_truthy
        route("TestController", "index", "/base/*slug").match("/base/").should be_falsey
      end
    end
  end
end
