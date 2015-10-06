require "../spec_helper"

module CarbonViewTest
  class TestController < CarbonController::Base
    def index
      @missing_method = "not missing"
    end
  end

  describe CarbonView::Base do
    it "delegates missing methods to the controller instance variables" do
      # controller = TestController.action("index", "request", "response")
      # controller.index
      # CarbonView::Base.new(controller).missing_method.should eq("not missing")
    end
  end
end
