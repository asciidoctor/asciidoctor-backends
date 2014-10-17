require 'nokogiri'
require 'adocspec/base_generator'
require 'adocspec/html_beautifier'
require 'adocspec/html_normalizer'

module AdocSpec
  class HtmlGenerator < BaseGenerator

    def render_asciidoc(input, suite_name, opts)
      opts[:header_footer] ||= [true] if suite_name.start_with? 'document'
      html = super

      nokogiri = opts[:header_footer] ? Nokogiri::HTML : Nokogiri::HTML::DocumentFragment
      html = nokogiri.parse(html).normalize!

      HtmlBeautifier.beautify html
    end
  end
end
