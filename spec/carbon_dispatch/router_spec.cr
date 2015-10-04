require "../spec_helper"

module CarbonDispatchTest
  class TestController < CarbonController::Base
    def index

    end

    def new

    end
  end

  class Router < CarbonDispatch::Router
    get "/new", controller: "test", action: "new"
    get "/", controller: "test", action: "index"
  end

  describe CarbonDispatch::Router do
    it "creates a router" do
      router = Router.new(Router.routes.dup)

      # puts router.inspect
    end
  end
end
