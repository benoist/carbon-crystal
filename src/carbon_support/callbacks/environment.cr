class CarbonSupport::Callbacks::Environment
  property :target, :halted, :value, :run_block
  alias ValueType = (String | Bool | Nil)
  def initialize(@target : CarbonSupport::Callbacks, @halted : Bool, @value : ValueType, &@run_block : -> String)

  end
end
