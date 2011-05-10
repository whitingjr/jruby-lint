module JRuby
  module Lint
    class CLI
      def initialize(args)
        process_options(args)
      end

      def process_options(args)
        require 'optparse'
        OptionParser.new do |opts|
          opts.banner = "Usage: jrlint [options] [files]"
          opts.separator ""
          opts.separator "Options:"

          opts.on_tail("-v", "--version", "Print version and exit") do
            require 'jruby/lint/version'
            puts "JRuby-Lint version #{VERSION}"
            exit
          end

          opts.on_tail("-h", "--help", "This message") do
            puts opts
            exit
          end
        end.parse!(args)
      end

      def run
        require 'jruby/lint'
        project = JRuby::Lint::Project.new
        puts "JRuby-Lint version #{JRuby::Lint::VERSION}"
        project.run
        puts "Processed #{project.files.size} file#{project.files.size == 1 ? '' : 's'}"
        if project.findings.empty?
          puts "OK"
          exit
        else
          exit 1
        end
      end
    end
  end
end
