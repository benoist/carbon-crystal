module CarbonDispatch
  class BodyProxy
    getter :body

    def initialize(@body)
    end

    def initialize(@body, &@block)
    end

    def path=(path)
      @path
    end

    def path
      @path.to_s
    end

    def is_path?
      @path && File.exists?(@path)
    end

    def to_s
      @body.to_s
    end

    def present?
      puts "body"
      p !@body.nil? && @body != ""
      !@body.nil? && @body != ""
    end

    def close
      block = @block
      block.call if block
    end
  end
end
