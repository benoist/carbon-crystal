require "./generators/view"

module Carbon
  class Generator
    macro inherited
      @@views = [] of Carbon::Generator::View.class
      @@empty_files = [] of String
    end

    def self.register_template(view)
      views << view
    end

    def self.empty_file(path)
      empty_files << path
    end

    def self.views
      @@views
    end

    def self.empty_files
      @@empty_files
    end

    macro template(name, template_path, full_path)
      class {{name.id}} < Carbon::Generator::View
        ecr_file "{{TEMPLATE_DIR.id}}/{{template_path.id}}"
        def full_path
          "#{config.dir}/#{{{full_path}}}"
        end
      end

      {{@type}}.register_template({{name.id}})
    end
  end
end
