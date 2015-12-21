module CarbonView
  module Helpers
    module CaptureHelper
      def capture(&block : -> Object)
        value = nil
        buffer = with_output_buffer { value = block.call }
        if (string = buffer.presence || value) && string.is_a?(String)
          ECR::Util.html_escape string
        end
      end

      def with_output_buffer(buf = nil)
        unless buf
          buf = CarbonSupport::SafeBuffer.new("")
        end
        self.output_buffer, old_buffer = buf, output_buffer
        yield
        output_buffer
      ensure
        self.output_buffer = old_buffer
      end
    end
  end
end
