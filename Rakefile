#!/usr/bin/env rake
$LOAD_PATH << File.expand_path('./lib')

Dir.glob('lib/tasks/*.rake').each do |file|
  import file
end

# When no task specified, run test.
task :default => :test
