require 'test_helper'
require 'tilt/haml'

class TestHamlHtml5 < DocTest::Test

  converter_opts template_dirs: 'haml/html5'

  generate_tests! DocTest::HTML::ExamplesSuite.new(paragraph_xpath: './div/p/node()')
end
