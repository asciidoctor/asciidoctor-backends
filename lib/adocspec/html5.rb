require 'htmlbeautifier'
require 'adocspec/base'

module AdocSpec
  class HTML5 < Base

    file_suffix '.html'

    def self.parse_suite(html)
      suite = {}
      current = {}
      in_comment = false

      html.each_line do |line|
        if line =~ /^<!--\s*\.([^ \n]+)/
          current[:content].chomp! unless current.empty?
          suite[$1.to_sym] = current = {content: ''}
          in_comment = ! line.chomp.end_with?('-->')
        elsif in_comment
          in_comment = ! line.chomp.end_with?('-->')
        else
          current[:content] << line
        end
      end
      current[:content].chomp!

      suite
    end

    def self.tidy_html(input)
      output = []
      HtmlBeautifier::Beautifier.new(output).scan(input.to_s)
      output.join
    end
  end
end
