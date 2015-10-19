require "../spec_helper"

describe CarbonDispatch::Request do
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
