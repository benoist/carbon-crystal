require "../spec_helper"

KEY_GENERATOR = CarbonSupport::CachingKeyGenerator.new(CarbonSupport::KeyGenerator.new("secret", 1))

def new_cookie_jar(headers = HTTP::Headers.new)
  cookies = CarbonDispatch::Cookies::CookieJar.new(KEY_GENERATOR)
  cookies.update(CarbonDispatch::Cookies::CookieJar.from_headers(headers))
  cookies
end

def cookie_header(cookies)
  http_headers = HTTP::Headers.new
  cookies.write(http_headers)
  http_headers["Set-Cookie"]
end

module CarbonDispatch
  describe Cookies::CookieJar do
    it "sets a cookie" do
      cookies = new_cookie_jar
      cookies.set "user_name", "david"
      cookie_header(cookies).should eq "user_name=david; path=/"
    end

    it "reads a cookie" do
      cookies = new_cookie_jar
      cookies.set "user_name", "Jamie"
      cookies["user_name"].should eq "Jamie"
    end

    it "sets a permanent cookie" do
      cookies = new_cookie_jar
      cookies.set "user_name", "Jamie"
      cookies.permanent.set "user_name", "Jamie"
      cookie_header(cookies).should eq "user_name=Jamie; path=/; expires=#{HTTP.rfc1123_date(20.years.from_now)}"
    end

    it "reads a permanent cookie" do
      cookies = new_cookie_jar
      cookies.permanent.set "user_name", "Jamie"
      cookies.permanent["user_name"].should eq "Jamie"
    end

    it "sets a cookie with escapable characters" do
      cookies = new_cookie_jar
      cookies.set "that & guy", "foo & bar => baz"
      cookie_header(cookies).should eq "that%20%26%20guy=foo%20%26%20bar%20%3D%3E%20baz; path=/"
    end

    it "sets the cookie with expiration" do
      cookies = new_cookie_jar
      cookies.set "user_name", "david", expires: Time.new(2005, 10, 10, 5)
      cookie_header(cookies).should eq "user_name=david; path=/; expires=Mon, 10 Oct 2005 05:00:00 GMT"
    end

    it "sets the cookie with http_only" do
      cookies = new_cookie_jar
      cookies.set "user_name", "david", http_only: true
      cookie_header(cookies).should eq "user_name=david; path=/; HttpOnly"
    end

    it "sets the cookie with secure if the jar is secure" do
      cookies = new_cookie_jar
      cookies.secure = true
      cookies.set "user_name", "david", secure: true
      cookie_header(cookies).should eq "user_name=david; path=/; Secure"
    end

    it "does not set the cookie with secure if the jar is insecure" do
      cookies = new_cookie_jar
      cookies.secure = false
      cookies.set "user_name", "david", secure: true
      cookie_header(cookies).should eq ""
    end

    it "sets the insecure cookie with if the jar is secure" do
      cookies = new_cookie_jar
      cookies.secure = true
      cookies.set "user_name", "david", secure: false
      cookie_header(cookies).should eq "user_name=david; path=/"
    end

    it "sets multiple cookies" do
      cookies = new_cookie_jar
      cookies.set "user_name", "david", expires: Time.new(2005, 10, 10, 5)
      cookies.set "login", "XJ-122"
      cookies.size.should eq 2
      cookie_header(cookies).should eq "user_name=david; path=/; expires=Mon, 10 Oct 2005 05:00:00 GMT,login=XJ-122; path=/"
    end

    it "sets an encrypted cookie" do
      cookies = new_cookie_jar
      cookies.encrypted.set "user_name", "david"
      cookies.encrypted["user_name"].should eq "david"
      cookie_header(cookies).should_not eq "user_name=david; path=/"
    end

    it "gets an encrypted cookie" do
      cookies = new_cookie_jar
      cookie = HTTP::Cookie::Parser.parse_cookies("user_name=YVpKaXlJN29vZUlwUnNuR3JzOVFPdEFwazFGWWNrYlpIUzhqU21YWWJDbz0tLVAvUldZaFZCQklLOW44ZGJLMDAramc9PQ%3D%3D--cead74d6b7a64512a499fef31483fd21d9e89b85378a3eaa440c7ac7f9cd6b94; path=/").first
      cookies[cookie.name] = cookie
      cookies.encrypted["user_name"].should eq "david"
    end

    it "ignores tampered cookie signature" do
      cookies = new_cookie_jar
      cookie = HTTP::Cookie::Parser.parse_cookies("user_name=YVpKaXlJN29vZUlwUnNuR3JzOVFPdEFwazFGWWNrYlpIUzhqU21YWWJDbz0tLVAvUldZaFZCQklLOW44ZGJLMDAramc9PQ%3D%3D--tampered; path=/").first
      cookies[cookie.name] = cookie
      cookies.encrypted["user_name"].should eq ""
    end

    it "ignores tampered cookie value" do
      cookies = new_cookie_jar(HTTP::Headers{"Cookie" => "user_name=tampered%3D%3D--cead74d6b7a64512a499fef31483fd21d9e89b85378a3eaa440c7ac7f9cd6b94;"})
      cookies.encrypted["user_name"].should eq ""
    end

    it "ignores unset encrypted cookies" do
      cookies = new_cookie_jar
      cookies.encrypted["invalid"].should eq nil
    end

    it "raises cookie overflow error" do
      cookies = new_cookie_jar
      expect_raises(Cookies::CookieOverflow) do
        cookies.encrypted["user_name"] = "long" * 2000
      end
    end

    it "deletes a cookie" do
      cookies = new_cookie_jar(HTTP::Headers{"Cookie" => "user_name=david"})
      cookies["user_name"].should eq "david"
      cookies.delete "user_name"
      cookie_header(cookies).should eq "user_name=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT"
    end

    it "allow deleting a unexisting cookie" do
      cookies = new_cookie_jar
      cookies.delete "invalid"
    end

    it "returns true if the cookie is delete" do
      cookies = new_cookie_jar(HTTP::Headers{"Cookie" => "user_name=david"})
      cookies.delete "user_name"
      cookies.deleted?("user_name").should eq true
    end
  end
end
