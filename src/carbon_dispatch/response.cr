module CarbonDispatch
  class Response
    delegate :headers, @response
    delegate "status_code=", @response
    delegate "status_code", @response
    delegate "close", @response

    property :path

    def initialize
      io = MemoryIO.new
      @response = HTTP::Server::Response.new(io)
      @rendered = false
      @path = ""
      @body = ""
      @callbacks = [] of ->
    end

    def initialize(@response : HTTP::Server::Response)
      @rendered = false
      @path = ""
      @body = ""
      @callbacks = [] of ->
    end

    def finish
      @callbacks.map { |callback| callback.call }
    end

    def register_callback(&block)
      @callbacks << block
    end

    def is_path?
      @path && File.exists?(@path)
    end

    def location=(location)
      @response.headers["Location"] = location
    end

    def location
      @response.headers["Location"]
    end

    def body
      @body
    end

    def body=(@body : String)
      @rendered = true
      @response.write(@body.to_slice)
    end

    def rendered?
      @rendered
    end
  end
end
