require 'test_helper'
require 'tilt/haml'

module Asciidoctor
  module DocTest
    class TestHamlHtml5 < HtmlTest

      templates_path 'haml/html5'

      generate_tests! AsciidocSuiteParser.new, HtmlSuiteParser.new(backend_name: :html5)
    end
  end
end
