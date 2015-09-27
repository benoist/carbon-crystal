require "option_parser"
require "ecr"
require "ecr/macros"
require "colorize"
require "./carbon/version"
require "./command/*"

module Carbon
  class Command
    USAGE = <<-USAGE
    Usage: carbon [command] [arguments]

    Command:
        app                      generate new crystal project
        --help, -h               show this help
        --version, -v            show version
    USAGE


    def self.run(options)
      self.new(options).run
    end

    def initialize(@options)
    end

    private getter options

    def run
      command = options.first?

      if command
        case
        when "app".starts_with?(command)
          options.shift
          app
        when "--help" == command, "-h" == command
          puts USAGE
          exit
        when "--version" == command, "-v" == command
          puts "Carbon #{Carbon::VERSION}"
          exit
        end
      else
        puts USAGE
        exit
      end
    end

    def app
      NewApp.run(options)
    end
  end
end

Carbon::Command.run(ARGV)
