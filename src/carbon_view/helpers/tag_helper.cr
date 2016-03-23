module CarbonView
  module Helpers
    module TagHelper
      include CaptureHelper
      include OutputSafetyHelper

      BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
        autoplay controls loop selected hidden scoped async
        defer reversed ismap seamless muted required
        autofocus novalidate formnovalidate open pubdate
        itemscope allowfullscreen default inert sortable
        truespeed typemustmatch).to_set

      # BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map { |attribute| attribute })

      TAG_PREFIXES = ["aria", "data", :aria, :data].to_set

      PRE_CONTENT_STRINGS = {
        "textarea" => "\n",
      }

      def tag(name, options = nil, open = false, escape = true)
        "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
      end

      def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true)
        content_tag_string(name, content_or_options_with_block, options, escape)
      end

      def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block : -> _)
        options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
        content_tag_string(name, capture(&block), options, escape)
      end

      def cdata_section(content)
        splitted = content.to_s.gsub(/\]\]\>/, "]]]]><![CDATA[>")
        "<![CDATA[#{splitted}]]>".html_safe
      end

      def escape_once(html)
        ECR::Util.html_escape_once(html)
      end

      private def content_tag_string(name, content, options, escape = true)
        tag_options = tag_options(options, escape) if options
        content = ECR::Util.unwrapped_html_escape(content) if escape
        "<#{name}#{tag_options}>#{PRE_CONTENT_STRINGS[name.to_s]?}#{content}</#{name}>".html_safe
      end

      private def tag_options(options, escape = true)
        return if options.blank?
        attrs = [] of String
        options.each do |key, value|
          if TAG_PREFIXES.includes?(key) && value.is_a?(Hash)
            value.each do |k, v|
              attrs << prefix_tag_option(key, k, v, escape)
            end
          elsif BOOLEAN_ATTRIBUTES.includes?(key)
            attrs << boolean_tag_option(key) if value
          elsif !value.nil?
            attrs << tag_option(key, value, escape)
          end
        end
        " #{attrs.join(" ")}" unless attrs.empty?
      end

      private def prefix_tag_option(prefix, key, value, escape)
        key = "#{prefix}-#{key.to_s.dasherize}"
        unless value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(BigDecimal)
          value = value.to_json
        end
        tag_option(key, value, escape)
      end

      private def boolean_tag_option(key)
        %(#{key}="#{key}")
      end

      private def tag_option(key, value, escape)
        if value.is_a?(Array)
          value = escape ? safe_join(value, " ") : value.flatten.join(" ")
        else
          value = escape ? ECR::Util.unwrapped_html_escape(value) : value
        end
        %(#{key}="#{value}")
      end
    end
  end
end
