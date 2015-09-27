guard 'process', :name => 'Spec', :command => 'crystal spec'  do
  watch(/spec\/(.*).e?cr$/)
  watch(/app\/(.*).e?cr$/)
end

guard 'process', :name => 'Build', :command => 'crystal build server.cr' do
  watch(/app\/(.*).e?cr$/)
end

guard 'process', :name => 'Server', :command => './server' do
  watch('server')
end
