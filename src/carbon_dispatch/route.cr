module CarbonDispatch
  class Route
    macro create(controller, action, methods, pattern)
      CarbonDispatch::Route.new "{{controller.id.camelcase}}Controller",
                                {{action}},
                                {{methods}},
                                {{pattern}},
                                ->(request : CarbonDispatch::Request, response : CarbonDispatch::Response) {
        {{controller.id.camelcase}}Controller.action({{action}}, request, response)
      }
    end

    getter controller, action, methods, pattern

    def initialize(@controller : String, @action : String, @methods : Array(String), path : String, @block : CarbonDispatch::Request, CarbonDispatch::Response -> Nil)
      @params = [] of String
      lparen = path.split(/(\()/)
      rparen = lparen.flat_map { |word| word.split(/(\))/) }
      params = rparen.flat_map { |word| word.split(/(:\w+)/) }
      slugged = params.flat_map { |word| word.split(/(\*\w+)/) }
      pattern = slugged.map do |word|
        word.gsub(/\(/) { "(?:" }
            .gsub(/\)/) { "){0,1}" }
            .gsub(/:(\w+)/) { @params << $1; "(?<#{$1}>[^/]+)" }
            .gsub(/\*(\w+)/) { @params << $1; "(?<#{$1}>.+)" }
      end.join

      @pattern = Regex.new("^#{pattern}$")
    end

    def match(method, path)
      return false unless @methods.includes?(method)

      path = normalize_path(path)

      match = path.to_s.match(@pattern)

      if match
        @params.reduce({} of String => String?) { |hash, param| hash[param] = match[param]?; hash }
      else
        false
      end
    end

    def normalize_path(path)
      path = "/#{path}"
      path = path.squeeze("/")
      path = path.sub(%r{/+\Z}, "")
      path = path.gsub(/(%[a-f0-9]{2})/) { $1.upcase }
      path = "/" if path == ""
      path
    end

    def call(request : CarbonDispatch::Request, response : CarbonDispatch::Response)
      @block.call(request, response)
    end

    def ==(other)
      @controller == other.controller && @action == other.action && @methods == other.methods && @pattern == other.pattern
    end
  end
end
