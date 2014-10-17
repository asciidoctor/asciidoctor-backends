require 'rake/testtask'

namespace :test do

  def test_task(backend, engine)
    namespace backend do
      Rake::TestTask.new(engine) do |task|
        task.pattern = "test/#{backend}_#{engine}_test.rb"
        task.libs << 'test'
      end
    end
  end

  test_task :html5, :haml
  test_task :html5, :slim

  task :html5 => ['html5:haml', 'html5:slim']
  task :all   => ['html5']
end

task :test => 'test:all'
