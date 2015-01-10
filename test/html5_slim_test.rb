require 'test_helper'

class TestSlimHtml5 < DocTest::Test

  converter_opts template_dirs: 'slim/html5'

  generate_tests! DocTest::HTML::ExamplesSuite.new(paragraph_xpath: './div/p/node()')
end
