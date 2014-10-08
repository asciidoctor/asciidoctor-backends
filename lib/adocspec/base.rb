require 'asciidoctor'
require 'pathname'

module AdocSpec
  class Base

    attr_accessor :backend_name, :templates_dir, :examples_dir, :file_suffix

    ##
    # Relative paths are referenced from the current working directory.
    #
    # @param backend_name [String] name of the tested Asciidoctor backend.
    #
    # @param file_suffix [String] filename extension of the suite files in
    #        {#examples_dir}. The default value may be specified with class
    #        constant +FILE_SUFFIX+. If not defined, +backend_name+ will be
    #        used instead.
    #
    # @param templates_dir [String, Pathname] path of the directory where to
    #        look for the backend's templates. The default is
    #        {AdocSpec.templates_path}/{#backend_name}.
    #
    # @param examples_dir [String, Pathname] path of the directory where to
    #        look for suites of testing examples. The default is
    #        {AdocSpec.examples_path}/{#backend_name}.
    #
    def initialize(backend_name: nil, file_suffix: nil, templates_dir: nil, examples_dir: nil)
      backend_name  ||= self.class.name.split('::').last.downcase
      @backend_name = backend_name.to_s

      file_suffix   ||= file_suffix || self.class::FILE_SUFFIX rescue @backend_name
      templates_dir ||= File.join(AdocSpec.templates_path, @backend_name)
      examples_dir  ||= File.join(AdocSpec.examples_path, @backend_name)

      @templates_dir = File.expand_path(templates_dir)
      @examples_dir  = File.expand_path(examples_dir)
      @file_suffix   = file_suffix.start_with?('.') ? file_suffix : '.' + file_suffix
    end

    ##
    # Resolves an absolute path of the examples suite.
    # The path is composed as +#{examples_dir}/#{suite_name}.#{file_suffix}+.
    #
    # @param suite_name [String]
    # @return [String]
    #
    def suite_path(suite_name)
      Pathname.new(suite_name).expand_path(examples_dir).sub_ext(file_suffix).to_s
    end

    ##
    # Returns names of all testing suites in {#examples_dir}, i.e. files with
    # {#file_suffix}.
    #
    # @return [Array<String>]
    #
    def suite_names
      Dir.glob("#{examples_dir}/*#{file_suffix}").map do |path|
        Pathname.new(path).basename.sub_ext('').to_s
      end
    end

    ##
    # @param suite_name [String]
    # @return [Hash] a parsed examples suite data ({#parse_suite format}),
    #         or an empty hash when no one exists.
    #
    def read_suite(suite_name)
      parse_suite File.read(suite_path(suite_name))
    rescue Errno::ENOENT
      {}
    end

    ##
    # Writes the examples suite to a file.
    #
    # @param suite_name [String] the name of the examples suite.
    # @param data [Hash] the examples suite data ({#parse_suite format}).
    # @see #suite_path
    #
    def write_suite(suite_name, data)
      File.open(suite_path(suite_name), 'w') do |file|
        file << render_suite(data)
      end
    end

    ##
    # Renders the given Asciidoc string with Asciidoctor using the backend's
    # templates in {#templates_dir}.
    #
    # @param text [String] the input text in Asciidoc syntax.
    # @param opts [Hash]
    # @option opts :header_footer whether to render a full document.
    # @return [String] the input text rendered in the tested syntax.
    #
    def render_asciidoc(text, opts = {})
      renderer_opts = {
        safe: :safe,
        template_dir: templates_dir,
        header_footer: opts.has_key?(:header_footer)
      }
      Asciidoctor.render(text, renderer_opts)
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
    # Renders the given suite of examples in Asciidoc syntax to the tested
    # syntax. This method is used when bootstrapping examples for an existing
    # backend (templates).
    #
    # @abstract
    # @param adoc_suite [Hash] the examples suite in Asciidoc syntax
    #        ({#parse_suite format}).
    # @return [String] the examples suite rendered in the tested syntax.
    #
    def render_suite(adoc_suite)
      raise NotImplementedError
    end
  end
end