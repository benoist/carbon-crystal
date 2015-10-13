require "../spec_helper"

module CarbonDispatchTest
  class TestController < CarbonController::Base
    def index

    end

    def new

    end
  end

  class Router < CarbonDispatch::Router
    get "/", controller: "test", action: "index"
    get "/new", controller: "test", action: "new"
  end

  describe CarbonDispatch::Router do
    it "creates routes" do
      router = Router.routes
      router.should be_a(Array(CarbonDispatch::Route))
    end

    it "adds routes" do
      routes = Router.routes
      routes[0].should eq CarbonDispatch::Route.create("test", "index", "/")
      routes[1].should eq CarbonDispatch::Route.create("test", "new", "/new")
    end
  end
end
