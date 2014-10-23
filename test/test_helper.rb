require 'asciidoctor-doctest'
require 'diffy'
require 'minitest/autorun'
require 'minitest/rg'
require 'tilt'

%w(test/examples/html5 test/examples/asciidoc-html).each do |path|
  Asciidoctor::DocTest.examples_path.unshift path
end

# Colorize diff!
Diffy::Diff.default_format = :color
