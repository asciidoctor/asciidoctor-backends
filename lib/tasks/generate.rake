require 'thread_safe'
require 'adocspec'
require 'asciidoctor'
require 'colorize'
require 'tilt/haml'

namespace :adocspec do
  namespace :generate do

    desc 'Generate testing examples for HTML5 backend'
    task :html5, [:suite_name] do |task, args|
      generate AdocSpec::HtmlSuiteParser.new(backend_name: :html5), args[:suite_name]
    end

    def generate(parser, suite=nil)
      adoc_parser = AdocSpec::AsciidocSuiteParser.new

      if suite && ! adoc_parser.suite_names.include?(suite)
        fail "Unknown suite name: #{suite}"
      end
      suites = suite ? [suite] : adoc_parser.suite_names
      force = !! ENV['force']

      suites.each do |name|
        file_name = File.basename(parser.suite_path(name))
        message = "Generating #{file_name}".green

        if File.exist? parser.suite_path(name)
          unless force
            answer = prompt("File #{file_name} already exist! Overwrite? (yes/no/all) ".blue, %w{yes no all})
            force = answer == 'all'
            next if answer == 'no'
          end
          message = "Regenerating #{file_name}".yellow
        end

        puts message
        adoc = adoc_parser.read_suite(name)
        parser.write_suite(name, adoc)
      end
    end
  end
end
