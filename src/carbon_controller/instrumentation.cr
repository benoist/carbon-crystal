module CarbonController
  module Instrumentation
    def process_action(name, block)
      puts "Started #{name}"
      super
      puts "Finished"
    end
  end
end
