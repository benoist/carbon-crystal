module CarbonController
  module Head
    def head(status, location : String? = nil, content_type : String? = nil)
      response.status_code = status
      response.location = location if location
      response.headers["Content-Type"] = content_type if content_type

      if include_content?(status)
        response.content_type = content_type # || (Mime[formats.first] if formats)
      else
        response.headers.delete("Content-Type")
        response.headers.delete("Content-Length")
      end

      true
    end

    private def include_content?(status)
      case status
      when 100..199
        false
      when 204, 205, 304
        false
      else
        true
      end
    end
  end
end
