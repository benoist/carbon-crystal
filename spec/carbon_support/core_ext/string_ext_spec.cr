module StringExtTest
  class NewObject
    def to_s
      "other"
    end
  end

  describe "OutputSafetyTest" do
    string = "hello"
    object = NewObject.new

    it "should be unsafe by default" do
      string.html_safe?.should eq false
    end

    it "should mark a string safe" do
      safe_string = string.html_safe
      safe_string.html_safe?.should eq true
    end

    it "returns the string after marking safe " do
      string.html_safe.should eq string
    end

    it "should be safe for numbers" do
      5.html_safe?.should eq true
    end

    it "should be safe for floats" do
      5.7.html_safe?.should eq true
    end

    it "should be unsafe for objects" do
      object.html_safe?.should eq false
    end

    it "returns a safe string when adding an object to a safe string" do
      safe_string = string.html_safe
      safe_string += object.to_s

      safe_string.should eq "helloother"
      safe_string.html_safe?.should eq true
    end

    it "returns a safe string when adding a safe string to another safe string " do
      other_string = "other".html_safe
      safe_string = string.html_safe
      combination = other_string + safe_string

      combination.should eq "otherhello"
      combination.html_safe?.should eq true
    end

    it "escapes it and returns a safe string when adding an unsafe string to a safe string" do
      other_string = "other".html_safe
      combination = other_string + "<foo>"
      other_combination = string + "<foo>"

      combination.should eq "other&lt;foo&gt;"
      other_combination.should eq "hello<foo>"

      combination.html_safe?.should eq true
      other_combination.html_safe?.should eq false
    end

    it "Concatting safe onto unsafe yields unsafe" do
      other_string = "other"

      string = string.html_safe
      other_string += string.to_s
      other_string.html_safe?.should eq false
    end

    it "Concatting unsafe onto safe yields escaped safe" do
      other_string = "other".html_safe
      string = other_string.concat("<foo>")
      string.should eq "other&lt;foo&gt;"
      string.html_safe?.should eq true
    end

    it "Concatting safe onto safe yields safe" do
      other_string = "other".html_safe
      string = string.html_safe

      other_string.concat(string)
      other_string.html_safe?.should eq true
    end

    it "Concatting safe onto unsafe with << yields unsafe" do
      other_string = "other"
      string = string.html_safe

      other_string += string.to_s
      other_string.html_safe?.should eq false
    end

    it "Concatting unsafe onto safe with << yields escaped safe" do
      other_string = "other".html_safe
      string = other_string + "<foo>"
      string.should eq "other&lt;foo&gt;"
      string.html_safe?.should eq true
    end

    it "Concatting safe onto safe with << yields safe" do
      other_string = "other".html_safe
      string = string.html_safe

      other_string += string
      other_string.html_safe?.should eq true
    end

    it "Concatting safe onto unsafe with % yields unsafe" do
      other_string = "other%s"
      string = string.html_safe

      other_string = other_string % string
      other_string.html_safe?.should eq false
    end

    it "Concatting unsafe onto safe with % yields escaped safe" do
      other_string = "other%s".html_safe
      string = other_string % "<foo>"

      string.should eq "other&lt;foo&gt;"
      string.html_safe?.should eq true
    end

    it "Concatting safe onto safe with % yields safe" do
      other_string = "other%s".html_safe
      string = string.html_safe

      other_string = other_string % string
      other_string.html_safe?.should eq true
    end

    it "Concatting with % doesn't modify a string" do
      other_string = ["<p>", "<b>", "<h1>"]
      _ = "%s %s %s".html_safe % other_string

      other_string.should eq ["<p>", "<b>", "<h1>"]
    end

    # it "Concatting a fixnum to safe always yields safe" do
    #   string = string.html_safe
    #   string = string.concat(13)
    #   string.should eq "hello".concat(13)
    #   session[:]tring.html_safe?.should eq true
    # end

    # it "emits normal string yaml" do
    #   "foo".html_safe.to_yaml(:foo => 1).should eq "foo".to_yaml
    # end

    # it "call to_param returns a normal string" do
    #   string = string.html_safe
    #   string.html_safe?.should eq true
    #   string.to_param.html_safe?.should eq false
    # end

    it "ERB::Util.html_escape should escape unsafe characters" do
      string = "<>&\"'"
      expected = "&lt;&gt;&amp;&quot;&#39;"
      ECR::Util.html_escape(string).should eq expected
    end

    it "ECR::Util.html_escape should correctly handle invalid UTF-8 strings" do
      string = "\251 <"
      expected = "© &lt;"
      ECR::Util.html_escape(string).should eq expected
    end

    it "ECR::Util.html_escape should not escape safe strings" do
      safe_string = "<b>hello</b>".html_safe
      ECR::Util.html_escape(safe_string).should eq "<b>hello</b>"
    end

    it "ECR::Util.html_escape_once only escapes once" do
      string = "1 < 2 &amp; 3"
      escaped_string = "1 &lt; 2 &amp; 3"

      ECR::Util.html_escape_once(string).should eq escaped_string
      ECR::Util.html_escape_once(escaped_string).should eq escaped_string
    end

    it "ECR::Util.html_escape_once should correctly handle invalid UTF-8 strings" do
      string = "\251 <"
      expected = "© &lt;"
      ECR::Util.html_escape_once(string).should eq expected
    end
  end
end
