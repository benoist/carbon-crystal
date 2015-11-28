module CarbonController # :nodoc:
  module Cookies
    def process_action(name, block)
      super
      request.cookie_jar.write(response.headers)
    end

    private def cookies
      request.cookie_jar
    end
  end
end
