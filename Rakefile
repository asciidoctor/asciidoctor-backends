#!/usr/bin/env rake

Dir['test/tasks/*.rake'].each do |file|
  import file
end

# When no task specified, run test.
task :default => :test
