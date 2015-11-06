class CarbonSupport::Callbacks::Environment(T)
  property :target, :halted, :value, :run_block

  def initialize(@target : T, @halted, @value, &block : -> Object)
    @run_block = block
  end
end
