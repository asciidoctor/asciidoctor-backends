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

    opts.fetch(:include, []).each do |xpath|
      actual = html_include(actual, xpath)
    end

    opts.fetch(:exclude, []).each do |xpath|
      actual = html_exclude(actual, xpath)
    end

    msg = message('Asciidoctor output is not equivalent to the expected HTML') do
      diff expected, actual
    end

    assert EquivalentXml.equivalent?(expected, actual, {element_order: false}), msg
  end

  def mu_pp(str)
    AdocSpec::HTML.tidy_html str
  end

  # Returns filtered HTML without nodes specified by the XPath expression.
  def html_exclude(html, xpath)
    Nokogiri::HTML::DocumentFragment.parse(html).tap { |doc|
      doc.xpath(xpath).each { |node| node.remove }
    }.to_html
  end

  # Returns filtered HTML with nodes specified by the XPath expression.
  def html_include(html, xpath)
    Nokogiri::HTML::DocumentFragment.parse(html).xpath(xpath).to_html
  end

  generate_tests!
end
