require "../../spec_helper"

def assert_equal(first, other)
  first.to_s.should eq other.to_s
end

def assert_match(regex, str)
  !!(regex =~ str)
end

class TestView < CarbonView::Base
end

module CarbonViewTest
  def self.tag(*args)
    TestView.new.tag(*args)
  end

  def self.content_tag(*args)
    TestView.new.content_tag(*args)
  end

  def self.content_tag(*args, &block : -> _)
    TestView.new.content_tag(*args, &block)
  end

  def self.cdata_section(*args)
    TestView.new.cdata_section(*args)
  end

  describe CarbonView::Helpers::TagHelper do
    it "returns a tag" do
      tag("br").should eq "<br />"
      tag(:br, {:clear => "left"}).should eq "<br clear=\"left\" />"
      tag("br", nil, true).should eq "<br>"
    end

    it "tag_options" do
      str = tag("p", {"class" => "show", :class => "elsewhere"})
      assert_match(/class="show"/, str)
      assert_match(/class="elsewhere"/, str)
    end

    it "tag_options_rejects_nil_option" do
      assert_equal "<p />", tag("p", {:ignored => nil})
    end

    it "tag_options_accepts_false_option" do
      assert_equal "<p value=\"false\" />", tag("p", {:value => false})
    end

    it "tag_options_accepts_blank_option" do
      assert_equal "<p included=\"\" />", tag("p", {:included => ""})
    end

    # it "tag_options_converts_boolean_option" do
    #   assert_dom_equal "<p disabled="disabled" itemscope="itemscope" multiple="multiple" readonly="readonly" allowfullscreen="allowfullscreen" seamless="seamless" typemustmatch="typemustmatch" sortable="sortable" default="default" inert="inert" truespeed="truespeed" />",
    #                    tag("p", :disabled => true, :itemscope => true, :multiple => true, :readonly => true, :allowfullscreen => true, :seamless => true, :typemustmatch => true, :sortable => true, :default => true, :inert => true, :truespeed => true)
    # end

    it "content_tag" do
      assert_equal "<a href=\"create\">Create</a>", content_tag("a", "Create", {"href" => "create"})
      content_tag("a", "Create", {"href" => "create"}).html_safe?.should eq true
      assert_equal content_tag("a", "Create", {"href" => "create"}),
        content_tag("a", "Create", {:href => "create"})
      assert_equal "<p>&lt;script&gt;evil_js&lt;/script&gt;</p>",
        content_tag(:p, "<script>evil_js</script>")
      assert_equal "<p><script>evil_js</script></p>",
        content_tag(:p, "<script>evil_js</script>", nil, false)
    end

    # it "content_tag_with_block_in_erb" do
    #   buffer = render_erb("<%= content_tag(:div) do %>Hello world!<% end %>")
    #   assert_dom_equal "<div>Hello world!</div>", buffer
    # end

    # it "content_tag_with_block_in_erb_containing_non_displayed_erb" do
    #   buffer = render_erb("<%= content_tag(:p) do %><% 1 %><% end %>")
    #   assert_dom_equal "<p></p>", buffer
    # end

    # it "content_tag_with_block_and_options_in_erb" do
    #   buffer = render_erb("<%= content_tag(:div, :class => "green") do %>Hello world!<% end %>")
    #   assert_dom_equal %(<div class="green">Hello world!</div>), buffer
    # end

    # it "content_tag_with_block_and_options_out_of_erb" do
    #   assert_dom_equal %(<div class="green">Hello world!</div>), content_tag(:div, :class => "green") { "Hello world!" }
    # end

    it "content_tag_with_block_and_options_outside_out_of_erb" do
      assert_equal content_tag("a", "Create", {:href => "create"}),
        content_tag("a", {"href" => "create"}) { "Create" }
    end

    it "content_tag_with_block_and_non_string_outside_out_of_erb" do
      content_tag("p") { 3.times { "do_something" } }.should eq content_tag("p")
    end

    # it "content_tag_nested_in_content_tag_out_of_erb" do
    #   assert_equal content_tag("p", content_tag("b", "Hello")),
    #                content_tag("p") { content_tag("b", "Hello") },
    #                output_buffer
    # end

    # it "content_tag_nested_in_content_tag_in_erb" do
    #   assert_equal "<p>\n  <b>Hello</b>\n</p>", view.render("test/content_tag_nested_in_content_tag")
    # end

    it "content_tag_with_escaped_array_class" do
      str = content_tag("p", "limelight", {:class => ["song", "play>"]})
      assert_equal "<p class=\"song play&gt;\">limelight</p>", str

      str = content_tag("p", "limelight", {:class => ["song", "play"]})
      assert_equal "<p class=\"song play\">limelight</p>", str

      str = content_tag("p", "limelight", {:class => ["song", ["play"]]})
      assert_equal "<p class=\"song play\">limelight</p>", str
    end

    it "content_tag_with_unescaped_array_class" do
      str = content_tag("p", "limelight", {:class => ["song", "play>"]}, false)
      assert_equal "<p class=\"song play>\">limelight</p>", str

      str = content_tag("p", "limelight", {:class => ["song", ["play>"]]}, false)
      assert_equal "<p class=\"song play>\">limelight</p>", str
    end

    it "content_tag_with_empty_array_class" do
      str = content_tag("p", "limelight", {:class => [] of String})
      assert_equal "<p class=\"\">limelight</p>", str
    end

    it "content_tag_with_unescaped_empty_array_class" do
      str = content_tag("p", "limelight", {:class => [] of String}, false)
      assert_equal "<p class=\"\">limelight</p>", str
    end

    # it "content_tag_with_data_attributes" do
    #   assert_dom_equal "<p data-number="1" data-string="hello" data-string-with-quotes="double&quot;quote&quot;party&quot;">limelight</p>",
    #                    content_tag("p", "limelight", data: { number: 1, string: "hello", string_with_quotes: "double"quote"party"" })
    # end

    it "cdata_section" do
      assert_equal "<![CDATA[<hello world>]]>", cdata_section("<hello world>")
    end

    it "cdata_section_with_string_conversion" do
      assert_equal "<![CDATA[]]>", cdata_section(nil)
    end

    it "cdata_section_splitted" do
      assert_equal "<![CDATA[hello]]]]><![CDATA[>world]]>", cdata_section("hello]]>world")
      assert_equal "<![CDATA[hello]]]]><![CDATA[>world]]]]><![CDATA[>again]]>", cdata_section("hello]]>world]]>again")
    end

    it "escape_once" do
      assert_equal "1 &lt; 2 &amp; 3", TestView.new.escape_once("1 < 2 &amp; 3")
      assert_equal " &#X27; &#x27; &#x03BB; &#X03bb; &quot; &#39; &lt; &gt; ", TestView.new.escape_once(" &#X27; &#x27; &#x03BB; &#X03bb; \" ' < > ")
    end

    it "tag_honors_html_safe_for_param_values" do
      ["1&amp;2", "1 &lt; 2", "&#8220;test&#8220;"].each do |escaped|
        assert_equal %(<a href="#{escaped}" />), tag("a", {:href => escaped.html_safe})
      end
    end

    it "tag_honors_html_safe_with_escaped_array_class" do
      str = tag("p", {:class => ["song>", "play>".html_safe]})
      assert_equal "<p class=\"song&gt; play>\" />", str

      str = tag("p", {:class => ["song>".html_safe, "play>"]})
      assert_equal "<p class=\"song> play&gt;\" />", str
    end

    it "skip_invalid_escaped_attributes" do
      ["&1;", "&#1dfa3;", "& #123;"].each do |escaped|
        assert_equal %(<a href="#{escaped.gsub(/&/, "&amp;")}" />), tag("a", {:href => escaped})
      end
    end

    it "disable_escaping" do
      assert_equal "<a href=\"&amp;\" />", tag("a", {:href => "&amp;"}, false, false)
    end

    # it "data_attributes" do
    #   ["data", :data].each { |data|
    #     assert_dom_equal "<a data-a-float="3.14" data-a-big-decimal="-123.456" data-a-number="1" data-array="[1,2,3]" data-hash="{&quot;key&quot;:&quot;value&quot;}" data-string-with-quotes="double&quot;quote&quot;party&quot;" data-string="hello" data-symbol="foo" />",
    #                      tag("a", { data => { a_float: 3.14, a_big_decimal: BigDecimal.new("-123.456"), a_number: 1, string: "hello", symbol: :foo, array: [1, 2, 3], hash: { key: "value" }, string_with_quotes: "double"quote"party"" } })
    #   }
    # end
    #
    # it "aria_attributes" do
    #   ["aria", :aria].each { |aria|
    #     assert_dom_equal "<a aria-a-float="3.14" aria-a-big-decimal="-123.456" aria-a-number="1" aria-array="[1,2,3]" aria-hash="{&quot;key&quot;:&quot;value&quot;}" aria-string-with-quotes="double&quot;quote&quot;party&quot;" aria-string="hello" aria-symbol="foo" />",
    #                      tag("a", { aria => { a_float: 3.14, a_big_decimal: BigDecimal.new("-123.456"), a_number: 1, string: "hello", symbol: :foo, array: [1, 2, 3], hash: { key: "value" }, string_with_quotes: "double"quote"party"" } })
    #   }
    # end
  end
end
