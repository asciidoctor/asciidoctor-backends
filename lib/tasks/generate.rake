require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/strip'
require 'adocspec'

namespace :generate do

  desc <<-EOS.strip_heredoc
    Generate testing examples for HTML5 backend

    Options (environment variables):
      PATTERN   glob pattern to select examples to (re)generate. [default: *:*]
                E.g. *:*, block_toc:basic, block*:*, *list:with*, ...
      ENGINE    templates use. [default: slim]
      FORCE     overwrite existing examples (yes/no)? [default: no]

  EOS
  task :html5 do |task|
    AdocSpec::HtmlGenerator.new(
      AdocSpec::AsciidocSuiteParser.new,
      AdocSpec::HtmlSuiteParser.new(backend_name: 'html5', examples_dir: File.join('examples', 'html5')),
      templates_dir('html5')
    ).generate! pattern, force?
  end

  def pattern
    ENV['PATTERN'] || '*:*'
  end

  def force?
    ['yes', 'y', 'true'].include? ENV['FORCE'].try(:downcase)
  end

  def templates_dir(backend)
    File.join (ENV['ENGINE'] || 'slim'), backend
  end
end
