require "ecr"
view_dir = ARGV[0]

output = [] of String

Dir.cd(view_dir) do
  Dir["**/*.ecr"].each do |f|
    namespaces = File.dirname(f).split("/").map(&.camelcase).join("::")

    file_name = File.basename(f, ".ecr")
    view_type = File.extname(file_name)[1..-1].camelcase
    view_name = File.basename(file_name, File.extname(file_name)).camelcase

    output << <<-RUBY
      class CarbonViews::#{namespaces}::#{view_name} < CarbonView::#{view_type}
        def to_s(__io__)
          #{ECR.process_file(f, "__io__")}
        end
      end

      CarbonView::Base.views << CarbonViews::#{namespaces}::#{view_name}
    RUBY
  end
end

puts output.join("\n")
