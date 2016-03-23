class CarbonSupport::Callbacks::Environment
  property :target, :halted, :value, :run_block

  def initialize(@target, @halted, @value, &block : -> _)
    @run_block = block
  end
end
