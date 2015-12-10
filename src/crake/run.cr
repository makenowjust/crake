require "option_parser"

require "./manager"
require "./logger"
require "./version"

module CRake
  # Runs CRake.
  #
  # It parses ARGV and runs tasks, so it should be called at the end of the script.
  def self.run(args = ARGV.dup)
    OptionParser.parse(args) do |p|
        p.banner = "crystal make.cr -- [option] [task]..."

        # Show tasks {{{
        p.on "-A", "--all", "show all tasks, then exit" do
          DSL::MANAGER.show_tasks all: true
          exit 0
        end
        p.on "-T", "--tasks", "show all tasks, which have an descriptions, then exit" do
          DSL::MANAGER.show_tasks all: false
          exit 0
        end
        # }}}
        # Output options {{{
        p.on "-v", "--verbose", "show many information" do
          DSL::MANAGER.log.level = Logger::Level::INFO
        end
        p.on "-d", "--debug", "show debug logs" do
          DSL::MANAGER.log.level = Logger::Level::DEBUG
        end
        p.on "--no-color", "no colored output" do
          DSL::MANAGER.log.color? = false
        end
        # }}}
        # Task options {{{
        p.on "--no-spawn", "not use `spawn` for running task" do
          DSL::MANAGER.spawn? = false
        end
        # }}}
        # Help and version {{{
        p.on "-h", "--help", "show this help" do
          puts p
          exit 0
        end
        p.on "-V", "--version", "show CRake version" do
          puts VERSION
          exit 0
        end
        # }}}
        p.unknown_args do |before, after|
          DSL::MANAGER.args = after
          before = %w(default) if before.empty?
          DSL::MANAGER.run before
        end
    end
  end
end
# vim:fdm=marker:
