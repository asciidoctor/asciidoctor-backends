require 'test_helper'

module AdocSpec
  class TestHamlHtml5 < HtmlTest

    templates_dir 'slim/html5'

    generate_tests! AsciidocSuiteParser.new, HtmlSuiteParser.new(backend_name: :html5)
  end
end
