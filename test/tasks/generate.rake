require 'asciidoctor/doctest'
require 'thread_safe'
require 'tilt'
require 'tilt/haml'

def engine
  ENV['ENGINE'] || 'slim'
end

def pattern
  ENV['PATTERN'] || '*:*'
end

namespace :generate do

  DocTest::GeneratorTask.new(:html5) do |task|
    task.title = "Generate testing examples #{pattern} for HTML5 using #{engine.capitalize} templates."

    task.output_suite = DocTest::HTML::ExamplesSuite.new(
      examples_path: 'test/examples/html5',
      paragraph_xpath: './div/p/node()'
    )
    task.converter_opts[:template_dirs] = File.join(engine, 'html5')
    task.examples_path.unshift 'test/examples/asciidoc-html'
  end
end
