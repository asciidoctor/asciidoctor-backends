require 'rake/testtask'

Rake::TestTask.new(:test) do |task|
  task.pattern = 'test/*_test.rb'
  task.libs << 'test'
end
