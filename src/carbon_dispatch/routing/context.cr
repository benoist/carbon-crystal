module CarbonDispatch
  module Routing
    class Context
      getter params

      def initialize(@params : Hash(String, String))
      end
    end
  end
end
