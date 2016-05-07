module CarbonSupport
  module Notifications
    class Payload
      property exception : Array(String?)?
      property message : String?

      macro define_property(name)
        class {{@type}}
          @{{name.id}} : String?
          def {{name.id}}
            @{{name.id}}
          end
          def {{name.id}}=(value)
            @{{name.id}} = value
          end
        end
      end

      def ==(other : Payload)
        exception == other.exception &&
          message == other.message
      end
    end
  end
end
