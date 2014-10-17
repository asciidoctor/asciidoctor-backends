require 'adocspec/base_suite_parser'

module AdocSpec
  class AsciidocSuiteParser < BaseSuiteParser

    FILE_SUFFIX = '.adoc'

    def parse_suite(adoc)
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
