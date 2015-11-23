require "./file_task"
require "./logger"
require "./rule"
require "./simple_task"

module CRake::DSL
  extend self

  # Manager and its delegates {{{

  # The default task manager.
  MANAGER = Manager.new

  {% for level in Logger::Level.constants.map &.id.downcase %}
    # Call `Manager#{{ level }}` with the default manager.
    def {{ level }}(message); MANAGER.{{ level }} message end
  {% end %}

  # Call `Manager#fatal` with the default manager.
  def fatal(message); MANAGER.fatal message end

  # Call `Manager#run` with the default manager.
  def run(*targets); MANAGER.run *targets end

  {% for name in [
      ["task", "SimpleTask", "targetdesc"],
      ["file", "FileTask", "target"],
      ["rule", "Rule::Task", "target"]].map &.map &.id %}
    # Call `Namespace::Mixin#{{ name[0] }}` with the default manager.
    def {{ name[0] }}({{ name[2] }}, deps = [] of String)
      MANAGER.{{ name[0] }} {{ name[2] }}, deps
    end

    # Call `Namespace::Mixin#{{ name[0] }}` with the default manager.
    def {{ name[0] }}({{ name[2] }}, deps = [] of String, &block : {{ name[1] }}::Info ->)
      MANAGER.{{ name[0] }} {{ name[2] }}, deps, &block
    end
  {% end %}

  # Call `Namespace::Mixin#namespace` with the default manager.
  def namespace(target, &block)
    MANAGER.namespace(target) do |namespace|
      with namespace yield namespace
    end
  end

  # }}}
  # Utilities {{{

  # Returns closure to change the file extension.
  def ext(ext) : String -> String
    ->(name : String){ name.sub /\.\w+\z/, ext }
  end

  # Run the command on shell.
  def sh(command)
    info "Run #{command.inspect} on shell"
    process = Process.new command, shell: true, input: false, output: true, error: true
    status = process.wait
    unless status.success?
      fatal "Failure command #{command.inspect} with status #{status.exit_status}"
    end
  end
  # }}}
end
# vim:fdm=marker:
