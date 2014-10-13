require 'pathname'

module AdocSpec
  class BaseSuiteParser

    attr_accessor :backend_name, :examples_dir, :file_suffix

    ##
    # Relative paths are referenced from the current working directory.
    #
    # @param backend_name [String] name of the tested Asciidoctor backend.
    #        The default is this class name (without module) in lowercase.
    #
    # @param file_suffix [String] filename extension of the suite files in
    #        {#examples_dir}. The default value may be specified with class
    #        constant +FILE_SUFFIX+. If not defined, +backend_name+ will be
    #        used instead.
    #
    # @param examples_dir [String, Pathname] path of the directory where to
    #        look for suites of testing examples. The default is
    #        {AdocSpec.examples_path}/{#backend_name}.
    #
    def initialize(backend_name: nil, file_suffix: nil, examples_dir: nil)
      backend_name  ||= self.class.name.split('::').last.sub('SuiteParser', '').downcase
      @backend_name = backend_name.to_s

      file_suffix   ||= file_suffix || self.class::FILE_SUFFIX rescue @backend_name
      examples_dir  ||= File.join(AdocSpec.examples_path, @backend_name)

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
    # Returns hash of testing examples that matches the +pattern+.
    #
    # @example
    #   filter_examples '*list*:basic*'
    #   => { block_colist: [ :basic ],
    #        listing:      [ :basic, :basic-nowrap, ... ],
    #        block_dlist:  [ :basic, :basic-block, ... ], ... }
    #
    # @param pattern [String] glob pattern to filter examples.
    # @return [Hash<Symbol, Array<Symbol>>]
    #
    def filter_examples(pattern)
      suite_glob, exmpl_glob = pattern.split(':')
      exmpl_glob ||= '*'
      results = {}

      suite_names.select { |suite_name|
        File.fnmatch(suite_glob, suite_name)

      }.each do |suite_name|
        suite = read_suite(suite_name)

        suite.keys.select { |exmpl_name|
          File.fnmatch(exmpl_glob, exmpl_name.to_s)
        }.each do |exmpl_name|
          (results[suite_name] ||= []) << exmpl_name
        end
      end

      results
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
    # @param data [Hash] the {#parse_suite examples suite}.
    # @see #suite_path
    #
    def write_suite(suite_name, data)
      File.open(suite_path(suite_name), 'w') do |file|
        file << serialize_suite(data)
      end
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
    # Serializes the given examples suite into string.
    # This method is used when bootstrapping examples for existing templates.
    #
    # @abstract
    # @param suite_hash [Hash] the {#parse_suite examples suite}.
    # @return [String]
    #
    def serialize_suite(suite_hash)
      raise NotImplementedError
    end
  end
end
