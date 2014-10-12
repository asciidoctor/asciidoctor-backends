require 'test_helper'

class TestSlimHtml5 < AdocSpec::HtmlTest

  templates_dir 'slim/html5'

  generate_tests! AdocSpec::Asciidoc.new, AdocSpec::HTML.new(backend_name: :html5)
end
