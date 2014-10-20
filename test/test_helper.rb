require 'asciidoctor-doctest'
require 'diffy'
require 'minitest/autorun'
require 'minitest/rg'
require 'tilt'

Asciidoctor::DocTest.examples_path.unshift 'test/examples/html5'

# Colorize diff!
Diffy::Diff.default_format = :color
