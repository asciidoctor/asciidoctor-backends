require 'adocspec/base'

module AdocSpec
  class Asciidoc < Base

    file_suffix '.adoc'

    def self.parse_suite(adoc)
      suite = {}
      current = {}

      adoc.each_line do |line|
        if line =~ /^\/\/\s*\.([^ \n]+)/
          current[:content].chomp! unless current.empty?
          suite[$1.to_sym] = current = {content: ''}
        elsif line.start_with? '//'
          next  # ignore for now
        else
          current[:content] << line
        end
      end
      current[:content].chomp!

      suite
    end
  end
end
