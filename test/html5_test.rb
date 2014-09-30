require 'test_helper'
require 'equivalent-xml'
require 'tilt/haml'

class TestHTML5 < AdocSpec::Test

  adocspec AdocSpec::HTML5

  def assert_example(expected, actual)
    msg = message('Asciidoctor output is not equivalent to the expected HTML') do
      diff expected, actual
    end
    opts = {element_order: false}

    assert EquivalentXml.equivalent?(expected, actual, opts), msg
  end

  def mu_pp(str)
    AdocSpec::HTML5.tidy_html str
  end

  generate_tests!
end
