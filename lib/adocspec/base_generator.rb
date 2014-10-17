require 'thread_safe'
require 'tilt'
require 'tilt/haml'
require 'asciidoctor'
require 'colorize'
require 'adocspec/core_ext'

module AdocSpec
  ###
  # Base generator for bootstrapping testing examples.
  class BaseGenerator

    ##
    # @param asciidoc_suite_parser [AdocSpec::Base] instance of suite parser to
    #        be used for reading the reference AsciiDoc examples.
    #
    # @param tested_suite_parser [AdocSpec::Base] instance of suite parser to
    #        be used for reading and writing the tested examples.
    #
    # @param templates_dir [String, Pathname] path of the directory where to
    #        look for the backend's templates.
    #
    # @param log_to destination where to write log messages (default: `$stdout`).
    #
    # @raise [StandardError] if the +templates_dir+ doesn't exist.
    #
    def initialize(asciidoc_suite_parser, tested_suite_parser, templates_dir, log_to: $stdout)
      @asciidoc_suite_parser = asciidoc_suite_parser
      @tested_suite_parser = tested_suite_parser
      @templates_dir = File.expand_path(templates_dir)
      @log_to = log_to

      unless Dir.exist? templates_dir
        raise "Templates directory '#{templates_dir}' doesn't exist!"
      end
    end

    ##
    # Generates missing, or rewrite existing, testing examples from the
    # AsciiDoctor reference examples converted using the backend templates
    # (specified by +templates_dir+ during initialization).
    #
    # @param pattern [String] glob-like pattern to select testing examples to
    #        (re)generate (see {BaseSuiteParser#filter_examples}).
    # @param rewrite [Boolean] whether to rewrite an already existing testing example.
    #
    def generate!(pattern = '*:*', rewrite = false)
      log do
        backend = @tested_suite_parser.backend_name
        tmpl = File.relative_path(@templates_dir)
        "Generating testing examples #{pattern} for #{backend} backend using #{tmpl} templates..."
      end

      filter_examples(pattern).each do |suite_name, exmpl_names|

        old_suite = read_tested_suite(suite_name)
        new_suite = {}

        read_asciidoc_suite(suite_name).each do |exmpl_name, adoc_exmpl|

          exmpl = old_suite.delete(exmpl_name) || {}
          new_suite[exmpl_name] = exmpl unless exmpl.empty?

          if exmpl_names.include? exmpl_name
            old_content = exmpl[:content] || ''
            new_content = render_asciidoc(adoc_exmpl.delete(:content), suite_name, adoc_exmpl)

            name = "#{suite_name}:#{exmpl_name}"
            log { status_message(name, old_content, new_content, rewrite) }

            if old_content.empty? || rewrite
              new_suite[exmpl_name] = exmpl.merge(content: new_content)
            end
          end
        end

        unless old_suite.empty?
          old_suite.each do |exmpl_name, exmpl|
            log "#{suite_name}:#{exmpl_name} doesn't exist in Asciidoctor's reference examples!".red
            new_suite[exmpl_name] = exmpl
          end
        end

        write_tested_suite suite_name, new_suite
      end
    end

    ##
    # Renders the given +input+ in AsciiDoc syntax with Asciidoctor using the
    # tested backend, i.e. templates specified by +templates_dir+.
    #
    # @param input [String] the input text in Asciidoc syntax.
    # @param suite_name [String] name of the examples suite that is a source of
    #        the given +input+.
    # @param opts [Hash]
    # @option opts :header_footer whether to render a full document.
    # @return [String] the input text rendered in the tested syntax.
    #
    def render_asciidoc(input, suite_name = '', opts = {})
      renderer_opts = {
        safe: :safe,
        template_dir: @templates_dir,
        header_footer: opts.has_key?(:header_footer)
      }
      Asciidoctor.render input, renderer_opts
    end

    ##
    # Builds a log message about the testing example (not) being (re)generated.
    def status_message(name, old_content, new_content, overwrite)
      msg = if old_content.empty?
              "Generating #{name}".magenta
            else
              if old_content.chomp == new_content.chomp
                "Unchanged #{name}".green
              elsif overwrite
                "Rewriting #{name}".red
              else
                "Skipping #{name}".yellow
              end
            end
      " --> #{msg}"
    end

    ##
    # Logs the +message+ to the destination specified by +log_to+ in
    # {#initialize} (default to `$stdout`) unless it the +log_to+ is nil.
    def log(message = nil, &block)
      message ||= block.call
      @log_to << message.chomp + "\n" if @log_to
    end


    def read_asciidoc_suite(suite_name)
      @asciidoc_suite_parser.read_suite suite_name
    end

    def read_tested_suite(suite_name)
      @tested_suite_parser.read_suite suite_name
    end

    def write_tested_suite(suite_name, data)
      @tested_suite_parser.write_suite suite_name, data
    end

    def filter_examples(pattern)
      @asciidoc_suite_parser.filter_examples pattern
    end
  end
end
