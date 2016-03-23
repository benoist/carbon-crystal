class MockRequest
  def initialize
  end

  def get(path : String, headers : HTTP::Headers)
    HTTP::Request.new("GET", path, headers)
  end

  def get(path : String, headers : Hash(String, String | Array(String)) = Hash(String, String | Array(String)).new)
    http_headers = HTTP::Headers.new

    headers.each do |key, value|
      http_headers.add(key, value)
    end

    HTTP::Request.new("GET", path, http_headers)
  end
end
