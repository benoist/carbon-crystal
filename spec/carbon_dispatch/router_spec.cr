require "../spec_helper"

module CarbonDispatchTest
  class TestRouter < CarbonDispatch::Router
    get "new", "application#new"
    get "", "application#index"
  end

  describe TestRouter do

  end
end
