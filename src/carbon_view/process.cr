require "ecr"
view_dir = ARGV[0]

output = [] of String

Dir.cd(view_dir) do
  Dir["**/*.ecr"].each do |f|
    file_name = File.basename(f, ".ecr")

    namespaces = File.dirname(f).split("/").map(&.camelcase).join("::")
    view_name = File.basename(file_name, File.extname(file_name)).camelcase

    if view_name.starts_with?("_")
      view_type = "Partial"
    else
      if namespaces.starts_with?("Layouts")
        view_type = "Layout"
      else
        view_type = "View"
      end
    end

    output << <<-RUBY
      class CarbonViews::#{namespaces}::#{view_name} < CarbonView::#{view_type}
        def to_s(__io__)
          #{ECR.process_file(f, "__io__")}
        end
      end
    RUBY

    if view_type == "Layout"
      output << %(CarbonView::Base.layouts["#{namespaces}::#{view_name}"] = CarbonViews::#{namespaces}::#{view_name})
    else
      output << %(CarbonView::Base.views["#{namespaces}::#{view_name}"] = CarbonViews::#{namespaces}::#{view_name})
    end
  end
end

puts output.join("\n")
