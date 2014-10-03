require 'asciidoctor'
require 'pathname'

module AdocSpec
  class Base
    class << self

      # @private
      def inherited(subclass)
        cls_name = subclass.name.split('::').last
        subclass.examples_dir File.join(AdocSpec.examples_path, cls_name.downcase)
        subclass.template_dir File.join(AdocSpec.templates_path, cls_name.downcase)
      end

      ##
      # Path of the directory where to look for the backend's templates.
      # Relative paths are referenced from the current working directory.
      #
      # Default path is derived from the +AdocSpec.templates_path+ and
      # this class name (without a module name) in lowercase.
      #
      # @param path [String, Pathname]
      #
      def template_dir(path)
        @template_dir = File.expand_path(path)
      end

      ##
      # Path of the directory where to look for example suites.
      # Relative paths are referenced from the current working directory.
      #
      # Default path is derived from the +AdocSpec.examples_path+ and this
      # class name (without a module name) in lowercase.
      #
      # @param path [String, Pathname]
      #
      def examples_dir(path)
        @examples_dir = File.expand_path(path)
      end

      ##
      # Filename extension of the suite files in the {examples_dir}.
      # This suffix will be added to the suite name when looking for a file.
      #
      # @param suffix [String]
      #
      def file_suffix(suffix)
        suffix = '.' + suffix unless suffix.start_with? '.'
        @file_suffix = suffix
      end

      ##
      # Resolves the absolute path of the examples suite.
      #
      # @param suite_name [String]
      # @return [String]
      #
      def suite_path(suite_name)
        Pathname.new(suite_name).expand_path(@examples_dir).sub_ext(@file_suffix).to_s
      end

      ##
      # @param suite_name [String]
      # @return [Hash] a parsed examples suite ({parse_suite format}), or an
      #   empty hash when no one exists.
      #
      def read_suite(suite_name)
        parse_suite File.read(suite_path(suite_name))
      rescue Errno::ENOENT
        {}
      end

      ##
      # Writes the examples suite to file.
      # The file path is composed as +#{examples_dir}/#{suite_name}.#{file_suffix}+.
      #
      # @param suite_name [String] the name of the examples suite.
      # @param data [Hash] the examples suite ({parse_suite format}).
      #
      def write_suite(suite_name, data)
        File.open(File.join(@examples_dir, suite_name + @file_suffix), 'w') do |file|
          file << render_suite(data)
        end
      end

      ##
      # Renders the given Asciidoc string with Asciidoctor using the template
      # specified by the {template_dir}.
      #
      # @param asciidoc [String] the input text in Asciidoc syntax.
      # @param opts [Hash] options.
      # @return [String] the input text rendered in the target syntax.
      #
      def render_adoc(asciidoc, opts = {})
        renderer_opts = {
          safe: :safe,
          template_dir: @template_dir,
          header_footer: opts.has_key?(:header_footer)
        }
        Asciidoctor.render(asciidoc, renderer_opts)
      end


      ##
      # Parses an examples suite and returns it as a hash.
      #
      # @example
      #   { :heading-h1 => { :content => "= Title" },
      #     :heading-h2 => { :content => "== Title", :include => ["//body"] } }
      #
      # @abstract
      # @param input [String] the suite's content to parse.
      # @return [Hash] the parsed examples suite.
      #
      def parse_suite(input)
        raise NotImplementedError
      end

      ##
      # Renders the given suite of examples in Asciidoc syntax to the target
      # syntax. This method is used when bootstrapping examples for an existing
      # backend (templates).
      #
      # @abstract
      # @param adoc_suite [Hash] the examples suite in Asciidoc syntax
      #                          ({parse_suite format}).
      # @return [String] the examples suite rendered in the target syntax.
      #
      def render_suite(adoc_suite)
        raise NotImplementedError
      end
    end
  end
end
