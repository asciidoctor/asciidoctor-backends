require 'test_helper'
require 'equivalent-xml'
require 'nokogiri'
require 'tilt/haml'

class TestHTML5 < AdocSpec::Test

  asciidoc_suite_reader AdocSpec::Asciidoc.new
  tested_suite_reader AdocSpec::HTML.new(backend_name: :html5)


  def render_asciidoc(adoc, opts)
    opts[:header_footer] = [true] if name.start_with? 'document'
    super
  end

  def assert_example(expected, actual, opts={})
    # When asserting inline examples, ignore paragraph "wrapper".
    if name.start_with?('inline_') && ! opts.has_key?(:include)
      opts[:include] = ['.//p/node()']
    end

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

  def mu_pp(str)
    AdocSpec::HTML.tidy_html str
  end

  def parse_html(str)
    Nokogiri::HTML::DocumentFragment.parse(str)
  end

  generate_tests!
end
