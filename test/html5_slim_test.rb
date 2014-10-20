require 'test_helper'

module Asciidoctor
  module DocTest
    class TestSlimHtml5 < HtmlTest

      templates_path 'slim/html5'

      generate_tests! AsciidocSuiteParser.new, HtmlSuiteParser.new(backend_name: :html5)
    end
  end
end
