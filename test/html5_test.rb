require 'test_helper'
require 'equivalent-xml'
require 'nokogiri'
require 'tilt/haml'

class TestHTML5 < AdocSpec::Test

  def self.read_tested_suite(suite_name)
    super.each_value do |opts|
      # Render 'document' examples as a full document with header and footer.
      opts[:header_footer] = [true] if suite_name.start_with? 'document'
      # When asserting inline examples, ignore paragraph "wrapper".
      opts[:include] ||= ['.//p/node()'] if suite_name.start_with? 'inline_'
    end
  end

  generate_tests! AdocSpec::Asciidoc.new, AdocSpec::HTML.new(backend_name: :html5)


  def assert_example(expected, actual, opts = {})
    actual = parse_html(actual)
    expected = parse_html(expected)

    # Select nodes specified by the XPath expression.
    opts.fetch(:include, []).each do |xpath|
      # xpath returns NodeSet, but we need DocumentFragment, so convert it again
      actual = parse_html(actual.xpath(xpath).to_html)
    end

    # Remove nodes specified by the XPath expression.
    opts.fetch(:exclude, []).each do |xpath|
      actual.xpath(xpath).each { |node| node.remove }
    end

    msg = message('Asciidoctor output is not equivalent to the expected HTML') do
      diff expected, actual
    end

    assert EquivalentXml.equivalent?(expected, actual), msg
  end

  ##
  # Returns a human-readable (formatted) version of +str+.
  # @note Overrides method from +Minitest::Assertions+.
  def mu_pp(str)
    AdocSpec::HTML.tidy_html(str)
  end

  def parse_html(str)
    Nokogiri::HTML::DocumentFragment.parse(str)
  end
end
