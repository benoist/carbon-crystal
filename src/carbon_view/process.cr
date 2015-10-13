require "ecr"

if File.exists?(ARGV[0])
  puts ECR.process_file(ARGV[0], ARGV[1])
else
  puts ECR.process_string("<% raise ViewNotFound.new(\"#{ARGV[0]}\") %>", ARGV[0])
end
# require "ecr"
#
# class ViewNotFound < Exception
#   getter :filename
#   def initialize(@filename)
#
#   end
#
#   def message
#     "View not found:#{@filename}"
#   end
# end
#
# class TestViews
#   macro embed_ecr(filename, io_name)
#     \{{ run("./src/carbon_view/process", {{filename}}, {{io_name}}) }}
#   end
#
#   def index(__io__)
#     @test = "aa"
#     embed_ecr "index.html", "__io__"
#   end
#
#   def blaat(__io__)
#     embed_ecr "blaat.html", "__io__"
#   end
# end
#
# str = StringIO.new
#
# TestViews.new.index(str)
# puts str
#
# begin
#   TestViews.new.blaat(str)
# rescue e : ViewNotFound
#   puts e.message
# end
