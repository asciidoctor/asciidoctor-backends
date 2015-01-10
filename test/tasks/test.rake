require 'rake/testtask'

namespace :test do

  def test_task(backend, engine)
    namespace backend do
      Rake::TestTask.new(engine) do |task|
        task.description = "Run tests for #{backend.upcase} backend (#{engine.capitalize} templates)"
        task.pattern = "test/#{backend}_#{engine}_test.rb"
        task.libs << 'test'
      end
    end
  end

  test_task :html5, :slim
  test_task :html5, :haml

  task :html5 => ['html5:slim', 'html5:haml']
  task :all   => ['html5']
end

task :test => 'test:all'
