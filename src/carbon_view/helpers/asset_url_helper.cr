module CarbonView
  module Helpers
    module AssetUrlHelper
      URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}i

      def asset_path(source, type = nil, extname = nil, host = nil, protocol = nil)
        source = source.to_s
        return "" unless source.present?
        return source if source =~ URI_REGEXP

        tail, source = source[/([\?#].+)$/]?, source.sub(/([\?#].+)$/, "")

        if (extname = compute_asset_extname(source, type: type, extname: extname))
          source = "#{source}#{extname}"
        end

        if source[0] != "/"
          source = compute_asset_path(source, type: type)
        end

        if (host = compute_asset_host(source, host: host, protocol: protocol))
          source = File.join(host, source)
        end

        "#{source}#{tail}"
      end

      def asset_url(source, type = nil, extname = nil, host = nil)
        path_to_asset(source, type, extname, host, :request)
      end

      ASSET_EXTENSIONS = {
        javascript: ".js",
        stylesheet: ".css",
      }

      # Compute extname to append to asset path. Returns nil if
      # nothing should be added.
      def compute_asset_extname(source, type = nil, extname = nil)
        return if extname == false
        extname = extname || ASSET_EXTENSIONS[type]?
        extname if extname && File.extname(source) != extname
      end

      # Maps asset types to public directory.
      ASSET_PUBLIC_DIRECTORIES = {
        audio:      "/audios",
        font:       "/fonts",
        image:      "/images",
        javascript: "/javascripts",
        stylesheet: "/stylesheets",
        video:      "/videos",
      }

      def compute_asset_path(source, type = nil)
        dir = ASSET_PUBLIC_DIRECTORIES[type]? || ""
        File.join(dir, source)
      end

      def compute_asset_host(source = "", host = nil, protocol = nil)
        request = self.request
        return unless request
        host ||= request.base_url if protocol == :request
        return unless host

        if host =~ URI_REGEXP
          host
        else
          protocol = protocol || (request ? :request : :relative)
          case protocol
          when :relative
            "//#{host}"
          when :request
            "#{request.protocol}#{host}"
          else
            "#{protocol}://#{host}"
          end
        end
      end

      def javascript_path(source, extname = nil, host = nil, protocol = nil)
        asset_path(source, :javascript, extname, host, protocol)
      end

      def javascript_url(source, extname = nil, host = nil)
        asset_url(source, :javascript, extname, host)
      end

      def stylesheet_path(source, extname = nil, host = nil, protocol = nil)
        asset_path(source, :stylesheet, extname, host, protocol)
      end

      def stylesheet_url(source, extname = nil, host = nil)
        asset_url(source, :stylesheet, extname, host)
      end

      def image_path(source, extname = nil, host = nil, protocol = nil)
        asset_path(source, :image, extname, host, protocol)
      end

      def image_url(source, extname = nil, host = nil)
        asset_url(source, :image, extname, host)
      end

      def video_path(source, extname = nil, host = nil, protocol = nil)
        asset_path(source, :video, extname, host, protocol)
      end

      def video_url(source, extname = nil, host = nil)
        asset_url(source, :video, extname, host)
      end

      def audio_path(source, extname = nil, host = nil, protocol = nil)
        asset_path(source, :audio, extname, host, protocol)
      end

      def audio_url(source, extname = nil, host = nil)
        asset_url(source, :audio, extname, host)
      end

      def font_path(source, extname = nil, host = nil, protocol = nil)
        asset_path(source, :font, extname, host, protocol)
      end

      def font_url(source, extname = nil, host = nil)
        asset_url(source, :font, extname, host)
      end
    end
  end
end
