require "ecr"

module ECR
  module Util
    HTML_ESCAPE             = {"&" => "&amp;", ">" => "&gt;", "<" => "&lt;", "\"" => "&quot;", "'" => "&#39;"}
    HTML_ESCAPE_REGEXP      = /[&"'><]/
    HTML_ESCAPE_ONCE_REGEXP = /["><']|&(?!([a-zA-Z]+|(#\d+)|(#[xX][\dA-Fa-f]+));)/

    def self.html_escape(s)
      unwrapped_html_escape(s).html_safe
    end

    def self.unwrapped_html_escape(s) # :nodoc:
      if s.html_safe?
        s
      else
        s.to_s.gsub(HTML_ESCAPE_REGEXP, HTML_ESCAPE)
      end
    end

    def self.html_escape_once(s)
      result = s.to_s.gsub(HTML_ESCAPE_ONCE_REGEXP, HTML_ESCAPE)
      s.html_safe? ? result.html_safe : result
    end
  end
end

class Object
  def html_safe?
    false
  end
end

struct Number
  def html_safe?
    true
  end
end

module CarbonSupport
  class SafeBuffer
    include Comparable(String)

    def ==(other)
      @string == other.to_s
    end

    def initialize(@string)
      @html_safe = true
      @string
    end

    def concat(value)
      @string += html_escape_interpolated_argument(value)
      self
    end

    def +(value)
      concat(value)
    end

    def %(args)
      case args
      when Hash
        escaped_args = Hash[args.map { |k, arg| [k, html_escape_interpolated_argument(arg)] }]
      when Array
        escaped_args = args.map { |arg| html_escape_interpolated_argument(arg) }
      else
        escaped_args = [args].map { |arg| html_escape_interpolated_argument(arg) }
      end

      self.class.new(@string % escaped_args)
    end

    def html_safe?
      !!@html_safe
    end

    def to_s(*args)
      @string.to_s(*args)
    end

    def inspect(*args)
      @string.inspect(*args)
    end

    def html_safe
      self
    end

    private def html_escape_interpolated_argument(arg)
      (!html_safe? || arg.html_safe?) ? arg.to_s : arg.to_s.gsub(ECR::Util::HTML_ESCAPE_REGEXP, ECR::Util::HTML_ESCAPE)
    end
  end
end

class String
  def html_safe
    CarbonSupport::SafeBuffer.new(self)
  end
end
