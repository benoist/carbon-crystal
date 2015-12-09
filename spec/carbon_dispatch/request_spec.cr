require "../spec_helper"

describe CarbonDispatch::Request do
  context "#scheme" do
    it "contains the scheme information" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/")
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("http")

      http_request = mock_http_request.get("/", {"HTTPS": "on"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("http")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com:8080"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("http")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com", "HTTPS": "on"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com:8443", "HTTPS": "on"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")
    end

    it "supports forwarded scheme information by proxies" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_SSL": "on"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com", "HTTP_X_FORWARDED_SSL": "on"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com:8443", "HTTP_X_FORWARDED_SSL": "on"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_SCHEME": "https"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com", "HTTP_X_FORWARDED_SCHEME": "https"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com:8443", "HTTP_X_FORWARDED_SCHEME": "https"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_PROTO": "https"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_PROTO": "https, http, http"})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_PROTO": ["https", "http", "http"]})
      request = CarbonDispatch::Request.new(http_request)
      request.scheme.should eq("https")
    end
  end

  context "#port" do
    it "contains the port information" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/")
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(80)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:8080"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(8080)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(80)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com:9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)

      http_request = mock_http_request.get("/", {"SERVER_NAME": "example.org", "SERVER_PORT": "9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com:9292", "SERVER_NAME": "example.com", "SERVER_PORT": "9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)
    end

    it "supports forwarded port information by proxies" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_PORT": "9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost", "HTTP_X_FORWARDED_PORT": "9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_PORT": "9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(92)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com", "HTTP_X_FORWARDED_PORT": "9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com:9595", "HTTP_X_FORWARDED_PORT": "9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9595)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(80)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com:9292"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com", "SERVER_PORT": "80"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(80)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com:9292", "SERVER_PORT": "80"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(9292)
    end

    it "derives the port information based on the scheme" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com", "HTTP_X_FORWARDED_SSL": "on"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com", "HTTP_X_FORWARDED_SCHEME": "https"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com", "HTTP_X_FORWARDED_PROTO": "https"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_HOST": "example.com", "HTTP_X_FORWARDED_PROTO": "https, http, http"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_SSL": "on", "SERVER_PORT": "80"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_SCHEME": "https", "SERVER_PORT": "80"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_PROTO": "https", "SERVER_PORT": "80"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:92", "HTTP_X_FORWARDED_PROTO": "https, http, http", "SERVER_PORT": "80"})
      request = CarbonDispatch::Request.new(http_request)
      request.port.should eq(443)
    end
  end

  context "#host_with_port" do
    it "returns the #host without the #port, with a #standard_port?" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("localhost")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:80"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("localhost")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:443"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("localhost")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost", "HTTP_X_FORWARDED_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("example.com")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost", "HTTP_X_FORWARDED_HOST": "example.com:80"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("example.com")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost", "HTTP_X_FORWARDED_HOST": "example.com:443"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("example.com")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:8080", "HTTP_X_FORWARDED_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("example.com")
    end

    it "returns the #host with the #port, without a #standard_port?" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:9393"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("localhost:9393")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost", "HTTP_X_FORWARDED_HOST": "example.com:9393"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("example.com:9393")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "localhost:93", "HTTP_X_FORWARDED_HOST": "example.com:9393"})
      request = CarbonDispatch::Request.new(http_request)
      request.host_with_port.should eq("example.com:9393")
    end
  end

  context "#host and #raw_host_with_port" do
    it "contains the host information" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"HOST": "localhost"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("localhost")
      request.raw_host_with_port.should eq("localhost")

      http_request = mock_http_request.get("/", {"HOST": "localhost:80"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("localhost")
      request.raw_host_with_port.should eq("localhost:80")

      http_request = mock_http_request.get("/", {"HOST": "localhost:94"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("localhost")
      request.raw_host_with_port.should eq("localhost:94")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "example.com:80"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:80")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "example.com:94"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:94")

      http_request = mock_http_request.get("/", {"SERVER_NAME": "example.com", "SERVER_PORT": "80"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:80")

      http_request = mock_http_request.get("/", {"SERVER_NAME": "example.com", "SERVER_PORT": "94"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:94")

      http_request = mock_http_request.get("/", {"HOST": "localhost", "HTTP_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("localhost")
      request.raw_host_with_port.should eq("localhost")

      http_request = mock_http_request.get("/", {"HOST": "localhost", "SERVER_NAME": "example.com", "SERVER_PORT": "94"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("localhost")
      request.raw_host_with_port.should eq("localhost")

      http_request = mock_http_request.get("/", {"HOST": "localhost", "HTTP_HOST": "www.example.com:94", "SERVER_NAME": "example.com", "SERVER_PORT": "94"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("localhost")
      request.raw_host_with_port.should eq("localhost")

      http_request = mock_http_request.get("/", {"HTTP_HOST": "www.example.com:94", "SERVER_NAME": "example.com", "SERVER_PORT": "94"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("www.example.com")
      request.raw_host_with_port.should eq("www.example.com:94")
    end

    it "supports forwarded host information by proxies" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_HOST": "example.com:80"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:80")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_HOST": "example.com:9494"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:9494")

      http_request = mock_http_request.get("/", {"HOST": "localhost", "HTTP_X_FORWARDED_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com")

      http_request = mock_http_request.get("/", {"HOST": "localhost:80", "HTTP_X_FORWARDED_HOST": "example.com:8080"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:8080")

      http_request = mock_http_request.get("/", {"HOST": "localhost", "HTTP_HOST": "example.com:8080", "HTTP_X_FORWARDED_HOST": "example.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com")

      http_request = mock_http_request.get("/", {"HOST": "localhost", "HTTP_HOST": "example.com", "HTTP_X_FORWARDED_HOST": "example.com:8080"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:8080")

      http_request = mock_http_request.get("/", {"SERVER_NAME": "example.com", "SERVER_PORT": "80", "HTTP_X_FORWARDED_HOST": "example.com:8080"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example.com")
      request.raw_host_with_port.should eq("example.com:8080")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_HOST": "example1.com, example2.com, example3.com"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example3.com")
      request.raw_host_with_port.should eq("example3.com")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_HOST": ["example1.com", "example2.com", "example3.com"]})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example3.com")
      request.raw_host_with_port.should eq("example3.com")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_HOST": "example1.com:80, example2.com:8080, example3.com:9494"})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example3.com")
      request.raw_host_with_port.should eq("example3.com:9494")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_HOST": ["example1.com:80", "example2.com:8080", "example3.com:9494"]})
      request = CarbonDispatch::Request.new(http_request)
      request.host.should eq("example3.com")
      request.raw_host_with_port.should eq("example3.com:9494")
    end
  end

  context "#ip" do
    it "contains the IP information" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "1.2.3.4"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("1.2.3.4")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "1.2.3.4,3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("1.2.3.4")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "1.2.3.4, 3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("1.2.3.4")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": ["1.2.3.4", "3.4.5.6"]})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("1.2.3.4")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "fe80::202:b3ff:fe1e:8329"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("fe80::202:b3ff:fe1e:8329")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "2620:0:1c00:0:812c:9583:754b:ca11,fd5b:982e:9130:247f:0000:0000:0000:0000"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "2620:0:1c00:0:812c:9583:754b:ca11, fd5b:982e:9130:247f:0000:0000:0000:0000"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": ["2620:0:1c00:0:812c:9583:754b:ca11", "fd5b:982e:9130:247f:0000:0000:0000:0000"]})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")
    end

    it "supports forwarded IP information by proxies" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "1.2.3.4", "HTTP_X_FORWARDED_FOR": "3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("1.2.3.4")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "1.2.3.4", "HTTP_X_FORWARDED_FOR": "3.4.5.6,7.8.9.0"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("1.2.3.4")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "1.2.3.4", "HTTP_X_FORWARDED_FOR": ["3.4.5.6", "7.8.9.0"]})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("1.2.3.4")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "3.4.5.6,7.8.9.0"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("7.8.9.0")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": ["3.4.5.6", "7.8.9.0"]})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("7.8.9.0")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "fe80::202:b3ff:fe1e:8329"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("fe80::202:b3ff:fe1e:8329")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "2620:0:1c00:0:812c:9583:754b:ca11,fd5b:982e:9130:247f:0000:0000:0000:0000"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": ["2620:0:1c00:0:812c:9583:754b:ca11", "fd5b:982e:9130:247f:0000:0000:0000:0000"]})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "unknown,3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "other,unknown,3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")
    end

    it "ignores trusted IP addresses" do
      mock_http_request = MockRequest.new

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "127.0.0.1,3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "192.168.0.1, 3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": ["10.0.0.1", "3.4.5.6"]})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": ["10.0.0.1", "10.0.0.1", "3.4.5.6"]})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "::1,2620:0:1c00:0:812c:9583:754b:ca11"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "2620:0:1c00:0:812c:9583:754b:ca11,::1"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "fd5b:982e:9130:247f:0000:0000:0000:0000,2620:0:1c00:0:812c:9583:754b:ca11"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("2620:0:1c00:0:812c:9583:754b:ca11")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "127.0.0.1", "HTTP_X_FORWARDED_FOR": "3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "127.0.0.1", "HTTP_X_FORWARDED_FOR": "10.0.0.1,3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "unix", "HTTP_X_FORWARDED_FOR": "3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"REMOTE_ADDR": "unix:/tmp/foo", "HTTP_X_FORWARDED_FOR": "3.4.5.6"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("3.4.5.6")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "unknown,192.168.0.1"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("unknown")

      http_request = mock_http_request.get("/", {"HTTP_X_FORWARDED_FOR": "other,unknown,192.168.0.1"})
      request = CarbonDispatch::Request.new(http_request)
      request.ip.should eq("unknown")
    end
  end

  context "#trusted_proxy?" do
    it "ignores local and trusted IP addresses" do
      mock_http_request = MockRequest.new
      http_request = mock_http_request.get("/", {"HOST": "host.example.org"})
      request = CarbonDispatch::Request.new(http_request)

      request.trusted_proxy?("127.0.0.1").should eq(0)
      request.trusted_proxy?("127.0.0.1").should eq(0)
      request.trusted_proxy?("10.0.0.1").should eq(0)
      request.trusted_proxy?("172.16.0.1").should eq(0)
      request.trusted_proxy?("172.20.0.1").should eq(0)
      request.trusted_proxy?("172.30.0.1").should eq(0)
      request.trusted_proxy?("172.31.0.1").should eq(0)
      request.trusted_proxy?("192.168.0.1").should eq(0)
      request.trusted_proxy?("::1").should eq(0)
      request.trusted_proxy?("fd00::").should eq(0)
      request.trusted_proxy?("localhost").should eq(0)
      request.trusted_proxy?("unix").should eq(0)
      request.trusted_proxy?("unix:/tmp/sock").should eq(0)

      request.trusted_proxy?("unix.example.org").should eq(nil)
      request.trusted_proxy?("example.org\n127.0.0.1").should eq(nil)
      request.trusted_proxy?("127.0.0.1\nexample.org").should eq(nil)
      request.trusted_proxy?("11.0.0.1").should eq(nil)
      request.trusted_proxy?("172.15.0.1").should eq(nil)
      request.trusted_proxy?("172.32.0.1").should eq(nil)
      request.trusted_proxy?("2001:470:1f0b:18f8::1").should eq(nil)
    end
  end
end
