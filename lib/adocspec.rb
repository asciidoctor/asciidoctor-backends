module AdocSpec

  @examples_path  = File.join(__dir__, '../examples')
  @templates_path = File.join(__dir__, '../haml')

  class << self
    attr_accessor :examples_path, :templates_path

    ##
    # Returns names of all Asciidoc test suites.
    # It actually returns names of files found in {examples_path}/asciidoc with
    # stripped +.adoc+ suffix.
    #
    # @return [Array<String>]
    #
    def suite_names
      Dir.glob("#{examples_path}/asciidoc/*").map do |path|
        Pathname.new(path).basename.sub_ext('').to_s
      end
    end
  end
end

require 'adocspec/base'
require 'adocspec/asciidoc'
require 'adocspec/html5'
