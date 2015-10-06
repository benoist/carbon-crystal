module CarbonDispatch
  class Static
    include Middleware
    def call(request, response)
      case request.method
        when "GET", "HEAD"
          file_path = Carbon.root.join("public", request.path).to_s
          if File.file?(file_path)
            response.status = 200
            response.headers = HTTP::Headers{"Content-Type": mime_type(file_path)}
            response.body = BodyProxy.new(File.read(file_path))

            return
          end
      end

      app.call(request, response)
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
