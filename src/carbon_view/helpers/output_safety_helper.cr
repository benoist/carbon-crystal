module CarbonView
  module Helpers
    module OutputSafetyHelper
      def raw(stringish)
        stringish.to_s.html_safe
      end

      def safe_join(array, sep = " ")
        sep = ECR::Util.unwrapped_html_escape(sep)

        array.flatten.map! { |i| ECR::Util.unwrapped_html_escape(i) }.join(sep).html_safe
      end
    end
  end
end
