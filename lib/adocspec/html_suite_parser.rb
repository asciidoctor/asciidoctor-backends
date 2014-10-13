require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/array/wrap'
require 'adocspec/base_suite_parser'

module AdocSpec
  class HtmlSuiteParser < BaseSuiteParser

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

    def serialize_suite(suite_hash)
      suite_hash.map { |key, hash|
        html = hash[:content].chomp
        opts = hash.except(:content)

        if opts.empty?
          "<!-- .#{key} -->\n#{html}\n"
        else
          opts_str = opts.map { |name, vals|
            Array.wrap(vals).map do |val|
              ['true', ''].include?(val.to_s) ? ":#{name}:" : ":#{name}: #{val}"
            end
          }.join("\n")

          "<!-- .#{key}\n#{opts_str}\n-->\n#{html}\n"
        end
      }.join("\n")
    end
  end
end
