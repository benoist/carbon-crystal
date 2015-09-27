module Carbon
  class Generator
    abstract class View
      getter config

      def initialize(@config)
      end

      def render
        Dir.mkdir_p(File.dirname(full_path))
        File.write(full_path, to_s)
        puts log_message unless config.silent
      end

      def log_message
        "      #{"create".colorize(:light_green)}  #{full_path}"
      end

      def module_name
        config.name.split("-").map(&.camelcase).join("::")
      end

      abstract def full_path
    end
  end
end
