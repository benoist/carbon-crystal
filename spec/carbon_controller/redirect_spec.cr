require "../spec_helper"

module CarbonControllerTest
  class RedirectTestController < CarbonController::Base
    def redirect_relative_path
      redirect_to "/foo"
    end

    def redirect_url
      redirect_to "http://www.example.com"
    end

    def redirect_url_with_status_hash
      redirect_to "http://www.example.com", {status: :permanent_redirect}
    end

    def redirect_to_url_with_unescaped_query_string
      redirect_to "http://example.com/query?status=new"
    end

    def redirect_to_url_with_complex_scheme
      redirect_to "x-test+scheme.complex:redirect"
    end

    def redirect_back
      redirect_to :back
    end

    def redirect_with_header_break
      redirect_to "/lol\r\nwat"
    end

    def redirect_with_null_bytes
      redirect_to "http://www.example.com\000/lol\r\nwat"
    end

    def redirect_nil
      redirect_to nil
    end

    def redirect_http_params
      redirect_to HTTP::Params.parse("foo=bar&foo=baz&baz=qux")
    end
  end
end

describe CarbonController::Redirect do
  context ".redirect_to" do
    it "redirects to a relative path" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_relative_path

      response.status.should eq(302)
      response.location.should eq("http://test.host/foo")
      response.body.to_s.should eq("")
    end

    it "redirects to a relative path with non standard port" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host:8888"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_relative_path

      response.status.should eq(302)
      response.location.should eq("http://test.host:8888/foo")
      response.body.to_s.should eq("")
    end

    it "redirects to a URL" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_url

      response.status.should eq(302)
      response.location.should eq("http://www.example.com")
      response.body.to_s.should eq("")
    end

    it "redirects to a URL with a custom HTTP status hash" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_url_with_status_hash

      response.status.should eq(308)
      response.location.should eq("http://www.example.com")
      response.body.to_s.should eq("")
    end

    it "redirects to a URL with unescaped query params" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_to_url_with_unescaped_query_string

      response.status.should eq(302)
      response.location.should eq("http://example.com/query?status=new")
      response.body.to_s.should eq("")
    end

    it "redirects to a complex schema" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_to_url_with_complex_scheme

      response.status.should eq(302)
      response.location.should eq("x-test+scheme.complex:redirect")
      response.body.to_s.should eq("")
    end

    it "redirects back based on the 'REFERER' HTTP header" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host", "REFERER": "http://www.example.com/hello_world"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_back

      response.status.should eq(302)
      response.location.should eq("http://www.example.com/hello_world")
      response.body.to_s.should eq("")
    end

    it "redirects to a relative path, even when there are header and line breaks in the path" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_with_header_break

      response.status.should eq(302)
      response.location.should eq("http://test.host/lolwat")
      response.body.to_s.should eq("")
    end

    it "redirects to a URL, even when there are null bytes in the URL" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)
      controller.redirect_with_null_bytes

      response.status.should eq(302)
      response.location.should eq("http://www.example.com/lolwat")
      response.body.to_s.should eq("")
    end

    it "raises RedirectBackError, when redirect back with blank 'REFERER' HTTP header" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host", "REFERER": ""})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)

      expect_raises CarbonController::RedirectBackError do
        controller.redirect_back
      end
    end

    it "raises RedirectBackError, when redirect back with NO 'REFERER' HTTP header" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)

      expect_raises CarbonController::RedirectBackError do
        controller.redirect_back
      end
    end

    it "raises CarbonControllerError, when redirect with nil" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)

      expect_raises CarbonController::CarbonControllerError do
        controller.redirect_nil
      end
    end

    it "raises CarbonControllerError, when redirect with HTTP::Params" do
      http_request = MockRequest.new.get("/", {"HOST": "test.host"})
      request = CarbonDispatch::Request.new(http_request)
      response = CarbonDispatch::Response.new

      controller = CarbonControllerTest::RedirectTestController.new(request, response)

      expect_raises CarbonController::CarbonControllerError do
        controller.redirect_http_params
      end
    end
  end
end
