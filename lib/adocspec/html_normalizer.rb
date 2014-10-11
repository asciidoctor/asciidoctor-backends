require 'active_support/core_ext/object'
require 'nokogiri'

module AdocSpec
  ##
  # Usage:
  #   Nokogiri::HTML.parse(str).normalize!
  #   Nokogiri::HTML::DocumentFragment.parse(str).normalize!
  module HtmlNormalizer

    ##
    # Normalizes the HTML document or fragment so it can be easily compared
    # with another HTML.
    #
    # What does it actually do?
    #
    # * sorts element attributes by name
    # * sorts inline CSS declarations inside a +style+ attribute by name
    # * removes all blank text nodes (i.e. node that contain just whitespaces)
    # * strips nonsignificant leading and trailing whitespaces around text
    # * strips nonsignificant repeated whitespaces
    #
    def normalize!
      self.traverse do |node|
        case node.type

        when Nokogiri::XML::Node::ELEMENT_NODE
          sort_element_attrs! node
          sort_element_style_attr! node

        when Nokogiri::XML::Node::TEXT_NODE
          # Remove text node that contains whitespaces only.
          if node.blank?
            node.remove

          elsif ! preformatted_block? node
            strip_redundant_spaces! node
            strip_spaces_around_text! node
          end
        end
      end
      self
    end

    private

    # Sorts attributes of the element +node+ by name.
    def sort_element_attrs!(node)
      node.attributes.sort_by(&:first).each do |name, value|
        node.delete(name)
        node[name] = value
      end
    end

    # Sorts CSS declarations in style attribute of the element +node+ by name.
    def sort_element_style_attr!(node)
      if node.has_attribute? 'style'
        decls = node['style'].scan(/([\w-]+):\s*([^;]+);/).sort_by(&:first)
        node['style'] = decls.map { |name, val| "#{name}: #{val};" }.join(' ')
      end
    end

    # Note: muttable methods like +gsub!+ doesn't work on node content.

    # Strips repeated whitespaces in the text +node+.
    def strip_redundant_spaces!(node)
      node.content = node.content.gsub("\n", ' ').gsub(/(\s)+/, '\1')
    end

    # Strips nonsignificant leading and trailing whitespaces in the text +node+.
    def strip_spaces_around_text!(node)
      node.content = node.content.lstrip if text_block_boundary? node, :left
      node.content = node.content.rstrip if text_block_boundary? node, :right
    end

    # Returns true if the text +node+ is the first (+:left+), or the last
    # (+:right) inline element of the nearest block element ancestor or direct
    # sibling of +<br>+ element.
    def text_block_boundary?(node, side)
      method = {left: :previous_sibling, right: :next_sibling}[side]

      return true if node.send(method).try(:name) == 'br'
      loop do
        if sibling = node.send(method)
          return false if sibling.text? || inline_element?(sibling)
        end
        node = node.parent
        return true unless inline_element? node
      end
    end

    HTML_INLINE_ELEMENTS = Nokogiri::HTML::ElementDescription::HTML_INLINE.flatten

    # Returns true if the +node+ represents an inline HTML element.
    def inline_element?(node)
      node.element? && HTML_INLINE_ELEMENTS.include?(node.name)
    end

    # Returns true if the +node+ is descendant of +<pre>+ node.
    def preformatted_block?(node)
      node.path =~ /\/pre\//
    end
  end
end

[Nokogiri::HTML::Document, Nokogiri::HTML::DocumentFragment].each do |klass|
  klass.send :include, AdocSpec::HtmlNormalizer
end
