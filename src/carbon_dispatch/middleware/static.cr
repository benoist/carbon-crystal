module CarbonDispatch
  class Static
    include Middleware
    def call(env)
      case env.request.method
        when "GET", "HEAD"
          file_path = Carbon.root.join("public", env.request.path).to_s
          if File.file?(file_path)
            return { 200, HTTP::Headers{"Content-Type": mime_type(file_path)}, BodyProxy.new(File.read(file_path)) }
          end
      end

      app.call(env)
    end

    private def mime_type(path)
      case File.extname(path)
      when ".txt" then "text/plain"
      when ".htm", ".html" then "text/html"
      when ".css" then "text/css"
      when ".js" then "application/javascript"
      else "application/octet-stream"
      end
    end
  end
end
