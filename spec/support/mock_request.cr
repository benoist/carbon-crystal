class MockRequest

  def initialize
  end

  def get(path : String, headers = Hash.new : Hash(String, String | Array(String)))
    http_headers = HTTP::Headers.new

    headers.each do |key, value|
      http_headers.add(key, value)
    end

    HTTP::Request.new("GET", path, http_headers)
  end

end
