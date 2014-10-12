require 'test_helper'
require 'tilt/haml'

class TestHamlHtml5 < AdocSpec::HtmlTest

  templates_dir 'haml/html5'

  generate_tests! AdocSpec::Asciidoc.new, AdocSpec::HTML.new(backend_name: :html5)
end
