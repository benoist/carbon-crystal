module Carbon
  class Command
    class NewApp

      def self.run(args)
        config = Config.new

        OptionParser.parse(args) do |opts|
          opts.banner = %{USAGE: carbon app NAME [DIR]
        NAME - name of project to be generated,
               eg: example
        DIR  - directory where project will be generated,
               default: NAME, eg: ./custom/path/example
        }

          opts.on("--help", "Shows this message") do
            puts opts
            exit
          end

          opts.unknown_args do |args, after_dash|
            config.name          = Helper.fetch_required_parameter(opts, args, "NAME")
            config.dir           = args.empty? ? config.name : args.shift
          end
        end

        NewAppGenerator.new(config).run
      end

      class Config
        property :name
        property :dir
        property :app_name
        property :silent

        def initialize(
            @name = "none",
            @dir = "none",
            @silent = false)
        end

        def app_name
          name.camelcase
        end
      end

      class NewAppGenerator < Generator
        TEMPLATE_DIR = "#{__DIR__}/new_app/template"

        def initialize(@config)
        end

        def run
          self.class.views.each do |view|
            view.new(@config).render
          end
          self.class.empty_files.each do |file|
            full_path = "#{@config.dir}/#{file}"
            Dir.mkdir_p(File.dirname(full_path))
            File.write(full_path, to_s)
            puts "      #{"create".colorize(:light_green)}  #{full_path}" unless @config.silent
          end
        end

        template GitignoreView, "gitignore.ecr", ".gitignore"
        template ServerView, "server.cr.ecr", "server.cr"
        template ApplicationControllerView, "application_controller.cr.ecr", "app/controllers/application_controller.cr"
        template WelcomeView, "welcome.html.ecr", "app/views/application/welcome.html.ecr"
        template ViewLayoutView, "application.html.ecr", "app/views/layouts/application.html.ecr"
        template ApplicationView, "application.cr.ecr", "config/application.cr"
        template EnvironmentView, "environment.cr.ecr", "config/environment.cr"
        template RoutesView, "routes.cr.ecr", "config/routes.cr"
        template RobotsView, "robots.txt.ecr", "public/robots.txt"
        template ShardView, "shard.yml.ecr", "shard.yml"
        template GuardfileView, "guardfile.yml.ecr", "Guardfile"

        empty_file "public/favicon.ico"
        empty_file "log/.gitkeep"
        empty_file "tmp/.gitkeep"
        empty_file "lib/.gitkeep"
      end
    end
  end
end
