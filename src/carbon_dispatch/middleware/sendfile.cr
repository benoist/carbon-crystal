module CarbonDispatch
  class Sendfile
    include Middleware

    def initialize(@variation)
      super()
    end

    def call(request, response)
      app.call(request, response)
      status = response.status_code
      headers = response.headers

      if response.is_path?
        case type = variation(request)
        when "X-Accel-Redirect"
          path = File.expand_path(response.path)
          if url = map_accel_path(request, path)
            headers["Content-Length"] = "0"
            headers[type] = url
          else
            Carbon.logger.error "X-Accel-Mapping header missing"
          end
        when "X-Sendfile", "X-Lighttpd-Send-File"
          path = File.expand_path(response.path)
          headers["Content-Length"] = "0"
          headers[type] = path
        else
          Carbon.logger.error "Unknown x-sendfile variation: '#{type}'.\n"
        end
      end
    end

    def variation(request)
      @variation || request.headers["HTTP_X_SENDFILE_TYPE"]
    end

    def map_accel_path(request, path)
      if mapping = request.headers["HTTP_X_ACCEL_MAPPING"]
        internal, external = mapping.split('=', 2).map { |p| p.strip }
        path.gsub(/^#{internal}/i, external)
      end
    end
  end
end
