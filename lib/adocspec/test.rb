require 'thread_safe'
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
    # Helper class for the examples suite that provides the class methods
    # +read_suite+ and +render_adoc+ (usually a subclass of {AdocSpec::Base}).
    #
    # @param klass [Class]
    # @raise [RuntimeError] if +klass+ doesn't respond to +read_suite+ or +render_adoc+.
    #
    def self.adocspec(klass)
      [:read_suite, :render_adoc].each do |name|
        raise "Class #{klass} doesn't respond to #{name}." unless klass.respond_to? name
      end

      define_singleton_method(:read_suite) do |suite_name|
        klass.read_suite(suite_name)
      end
      define_method(:render_adoc) do |asciidoc|
        klass.render_adoc(asciidoc)
      end
    end

    ##
    # Generates the test methods.
    # @note This macro must be called as the last statement of a subclass!
    def self.generate_tests!
      AdocSpec.suite_names.each do |name|
        suite = read_suite(name)

        AdocSpec::Asciidoc.read_suite(name).each do |key, data|
          test_name = "#{name} : #{key}"

          if suite && suite.has_key?(key)
            opts = suite[key]
            expected = opts.delete(:content)
            asciidoc = data[:content]

            define_test(test_name) do
              assert_example expected, render_adoc(asciidoc), opts
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
