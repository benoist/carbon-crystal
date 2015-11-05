require "../spec_helper"

module CarbonDispatchTest
  extend self

  def route(controller, action, method, path, app = app)
    CarbonDispatch::Route.new(controller, action, method, path, app)
  end

  def app
    ->(request : CarbonDispatch::Request, response : CarbonDispatch::Response) {}
  end

  describe CarbonDispatch::Route do
    context "pattern" do
      it "matches normal string" do
        route("TestController", "index", ["GET"], "/").match("GET", "/").should be_truthy
        route("TestController", "index", ["GET"], "/foo").match("GET", "/foo").should be_truthy
        route("TestController", "index", ["GET"], "/foo").match("GET", "/").should be_falsey
      end

      it "matches with named_params" do
        route("TestController", "index", ["GET"], "/base/:id").match("GET", "/base/1").should be_truthy
        route("TestController", "index", ["GET"], "/base/:id").match("GET", "/base/1/").should be_truthy
        route("TestController", "index", ["GET"], "/base/:id").match("GET", "/base/1/foo").should be_falsey
      end

      it "matches with optional params" do
        route("TestController", "index", ["GET"], "/base(:option)").match("GET", "/base").should be_truthy
        route("TestController", "index", ["GET"], "/base(:option)").match("GET", "/base1").should be_truthy
        route("TestController", "index", ["GET"], "/base(:option)").match("GET", "/base/a").should be_falsey
        route("TestController", "index", ["GET"], "/base(/:option)").match("GET", "/base/1").should be_truthy
        route("TestController", "index", ["GET"], "/base(/:option/fixed)").match("GET", "/base/1").should be_falsey
        route("TestController", "index", ["GET"], "/base(/:option/fixed)").match("GET", "/base/12/fixed").should be_truthy
      end

      it "matches with slugged param" do
        route("TestController", "index", ["GET"], "/base/*slug").match("GET", "/base/foo").should be_truthy
        route("TestController", "index", ["GET"], "/base/*slug").match("GET", "/base/foo/bar").should be_truthy
        route("TestController", "index", ["GET"], "/base/*slug").match("GET", "/base/").should be_falsey
      end
    end

    context "method" do
      it "matches against the request method" do
        route("TestController", "index", ["GET"], "/").match("POST", "/").should be_falsey
        route("TestController", "index", ["POST"], "/").match("POST", "/").should be_truthy
      end

      it "matches againt any method in the list" do
        route("TestController", "index", ["GET", "POST"], "/").match("POST", "/").should be_truthy
        route("TestController", "index", ["GET", "POST"], "/").match("PATCH", "/").should be_falsey
      end
    end
  end
end
