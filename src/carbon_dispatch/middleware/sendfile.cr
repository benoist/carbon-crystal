module CarbonDispatch
  class Sendfile
    include Middleware
    def initialize(@variation)
      super()
    end

    def call(env)
      status, headers, body = app.call(env)

      if body.is_path?
        case type = variation(env)
          when "X-Accel-Redirect"
            path = File.expand_path(body.path)
            if url = map_accel_path(env, path)
              headers["Content-Length"] = "0"
              headers[type]             = url
              body                      = BodyProxy.new(nil)
            else
              env.errors.puts "X-Accel-Mapping header missing"
            end
          when "X-Sendfile", "X-Lighttpd-Send-File"
            path = File.expand_path(body.path)
            headers["Content-Length"] = "0"
            headers[type]             = path
            body                      = BodyProxy.new(nil)
          else
            env.errors.puts "Unknown x-sendfile variation: '#{type}'.\n"
        end
      end
      { status, headers, body }
    end

    def variation(env)
      @variation || env.request.headers["HTTP_X_SENDFILE_TYPE"]
    end

    def map_accel_path(env, path)
      if mapping = env.request.headers["HTTP_X_ACCEL_MAPPING"]
        internal, external = mapping.split('=', 2).map{ |p| p.strip }
        path.gsub(/^#{internal}/i, external)
      end
    end
  end
end
