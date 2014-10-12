require 'test_helper'
require 'tilt/haml'

class TestHtml5 < AdocSpec::HtmlTest

  generate_tests! AdocSpec::Asciidoc.new, AdocSpec::HTML.new(backend_name: :html5)
end
