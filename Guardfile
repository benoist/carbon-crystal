guard 'process', :name => 'Spec', :command => 'crystal spec'  do
  watch(/spec\/(.*).cr$/)
  watch(/src\/(.*).cr$/)
  watch(/example\/(.*).cr$/)
end

guard 'process', :name => 'Build', :command => 'crystal build server.cr', dir: "example" do
  watch(/src\/(.*).cr$/)
  watch(/example\/(.*).cr$/)
end

guard 'process', :name => 'Server', :command => './server', dir: "example" do
  watch('example/server')
end

guard 'process', :name => 'Worksheet', :command => 'crystal run worksheet.cr' do
  watch(/src\/(.*).cr$/)
  watch('worksheet.cr')
end

guard 'process', :name => 'Format', :command => 'crystal tool format' do
  watch(/src\/(.*).cr$/)
  watch(/spec\/(.*).cr$/)
end
