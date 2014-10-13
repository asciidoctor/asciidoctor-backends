module AdocSpec

  @examples_path  = File.join(__dir__, '../examples')
  @templates_path = File.join(__dir__, '../haml')

  class << self
    attr_accessor :examples_path, :templates_path
  end
end

require 'adocspec/core_ext'
require 'adocspec/base_suite_parser'
require 'adocspec/asciidoc_suite_parser'
require 'adocspec/html_suite_parser'
require 'adocspec/base_test'
require 'adocspec/html_test'
require 'adocspec/base_generator'
require 'adocspec/html_generator'
