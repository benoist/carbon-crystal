class CarbonSupport::Callbacks::CallbackOptions
  getter :terminator, :if, :unless

  def initialize(@terminator = nil, @if = nil, @unless = nil, @skip_after_callbacks_if_terminated = false)
  end
end
