require 'active_support/core_ext/hash'
require 'adocspec/base'
require 'htmlbeautifier'

module AdocSpec
  class HTML < Base

    FILE_SUFFIX = '.html'

    def parse_suite(html)
      suite = {}
      current = {}
      in_comment = false

      html.each_line do |line|
        if line =~ /^<!--\s*\.([^ \n]+)/
          current[:content].chomp! unless current.empty?
          suite[$1.to_sym] = current = {content: ''}
          in_comment = ! line.chomp.end_with?('-->')
        elsif in_comment
          if line =~ /^\s*:([^:]+):(.*)/
            (current[$1.to_sym] ||= []) << $2.strip
          end
          in_comment = ! line.chomp.end_with?('-->')
        else
          current[:content] << line
        end
      end
      current[:content].chomp!

      suite
    end

    def write_suite(suite_name, data)
      # render 'document' as a document (with header and footer)
      if suite_name == 'document'
        data.each_value { |opts| opts[:header_footer] = [true] }
      end
      super
    end

    def render_suite(data)
      data.map { |key, hash|
        opts = hash.except(:content)
        html = HTML.tidy_html(render_asciidoc(hash[:content], opts))

        if opts.empty?
          "<!-- .#{key} -->\n#{html}\n"
        else
          opts_str = opts.map { |k, v| ":#{k}: #{v}" }.join("\n")
          "<!-- .#{key}\n#{opts_str}\n-->\n#{html}\n"
        end
      }.join("\n")
    end

    def self.tidy_html(input)
      output = []
      HtmlBeautifier::Beautifier.new(output).scan(input.to_s)
      output.join
    end
  end
end
