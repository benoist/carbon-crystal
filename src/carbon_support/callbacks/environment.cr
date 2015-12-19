class CarbonSupport::Callbacks::Environment
  property :target, :halted, :value, :run_block

  def initialize(@target, @halted, @value, &block : -> Object)
    @run_block = block
  end
end
