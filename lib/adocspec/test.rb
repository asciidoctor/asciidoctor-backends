require 'thread_safe'
require 'active_support/core_ext/object'
require 'asciidoctor'
require 'adocspec'
require 'diffy'
require 'minitest'

module Minitest
  module Diffy

    def self.included(base)
      base.make_my_diffs_pretty!
    end

    def diff(exp, act)
      expected = mu_pp_for_diff(exp)
      actual = mu_pp_for_diff(act)

      if need_diff?(expected, actual)
        ::Diffy::Diff.new(expected, actual, context: 3).to_s
            .insert(0, "\n")
            .gsub(/^\\ No newline at end of file\n/, '')
      else
        "Expected: #{mu_pp(exp)}\n  Actual: #{mu_pp(act)}"
      end
    end

    private
    def need_diff?(expected, actual)
      expected.include?("\n") ||
        actual.include?("\n") ||
        expected.size > 30    ||
        actual.size > 30      ||
        expected == actual
    end
  end
end

module AdocSpec

  ###
  # Base class for integration tests of Asciidoctor backends.
  class Test < Minitest::Test
    include Minitest::Diffy

    ##
    # Defines a new test method.
    #
    # @param name [String] name of the test (method).
    # @param block [Proc] the test method's body.
    #
    def self.define_test(name, &block)
      (@test_methods ||= []) << name
      define_method(name, block)
    end

    ##
    # @note Overrides method from +Minitest::Test+.
    # @return [Array] names of the test methods to run.
    def self.runnable_methods
      (@test_methods || []) + super
    end

    ##
    # @see AdocSpec::Base#read_suite
    def self.read_asciidoc_suite(suite_name)
      @asciidoc_suite_reader.read_suite(suite_name)
    end

    ##
    # Returns names of all testing suites.
    # @return [Array<String>]
    def self.suite_names
      @asciidoc_suite_reader.suite_names
    end

    ##
    # @see AdocSpec::Base#read_suite
    def self.read_tested_suite(suite_name)
      @tested_suite_reader.read_suite(suite_name)
    end

    ##
    # Generates the test methods.
    #
    # @param asciidoc_suite_reader [AdocSpec::Base] instance of AdocSpec reader
    #        to be used for reading the reference AsciiDoc examples.
    #
    # @param tested_suite_reader [AdocSpec::Base] instance of AdocSpec reader
    #        to be used for reading the tested examples.
    #
    def self.generate_tests!(asciidoc_suite_reader, tested_suite_reader)
      @asciidoc_suite_reader = asciidoc_suite_reader
      @tested_suite_reader = tested_suite_reader

      suite_names.each do |suite_name|
        tested_suite = read_tested_suite(suite_name)

        read_asciidoc_suite(suite_name).each do |exmpl_name, adoc|
          test_name = "#{suite_name} : #{exmpl_name}"

          if opts = tested_suite.try(:[], exmpl_name)
            expected = opts.delete(:content)
            asciidoc = adoc[:content]

            define_test(test_name) do
              actual = render_asciidoc(asciidoc, opts)
              assert_example expected, actual, opts
            end
          else
            define_test(test_name) do
              skip 'No example found'
            end
          end
        end
      end
    end


    ##
    # Renders the given text in AsciiDoc syntax with Asciidoctor using the
    # tested backend (templates).
    #
    # @see AdocSpec::Base#render_asciidoc
    #
    def render_asciidoc(text, opts = {})
      reader = self.class.instance_variable_get(:@tested_suite_reader)
      reader.render_asciidoc(text, opts)
    end

    ##
    # @note Overrides method from +Minitest::Test+.
    # @return [String] the name of this test that will be printed in a report.
    def location
      "#{self.class} :: #{self.name}"
    end

    ##
    # Asserts an actual rendered example against the expected from the examples
    # suite.
    #
    # @note This method may be overriden to provide a more suitable assert.
    #
    # @param expected [String] the expected output.
    # @param actual [String] the actual rendered output.
    # @param opts [Hash] options.
    # @raise [Minitest::Assertion] if the assertion fails
    #
    def assert_example(expected, actual, opts={})
      assert_equal expected, actual
    end
  end
end
