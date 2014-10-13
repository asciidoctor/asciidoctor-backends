require 'test_helper'
require 'tilt/haml'

module AdocSpec
  class TestHamlHtml5 < HtmlTest

    templates_dir 'haml/html5'

    generate_tests! AsciidocSuiteParser.new, HtmlSuiteParser.new(backend_name: :html5)
  end
end
