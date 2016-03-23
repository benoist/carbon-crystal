module CarbonView
  module Helpers
    module CaptureHelper
      def capture(&block : -> _)
        value = block.call
        ECR::Util.html_escape value if value.is_a?(String)
      end
    end
  end
end
