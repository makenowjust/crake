require "./error"
require "./namespace"
require "./logger"
require "./rule"
require "./task"

# A task manager.
class CRake::Manager
  include Namespace::Mixin

  # Internal types {{{

  # :nodoc:
  record TopLevelTask, deps do
    def name
      "##toplevel##"
    end

    def timestamp
      Time::MinValue
    end

    def run(manager); end
  end

  # :nodoc:
  record FallbackFileTask, name do
    include FileTask::Mixin

    def deps
      [] of String
    end

    def run(manager); end
  end

  # }}}
  # Constructor {{{

  # Create a new manager.
  def initialize(io = STDERR)
    @namespaces = {} of String => Namespace
    @tasks = {} of String => Task
    @rules = [] of Rule
    @log = Logger.new(io)
    @spawn = true
  end

  # }}}
  # Properties {{{

  # Returns its `Logger` instance.
  getter log

  # Returns optional arguments after `--`.
  #
  # ```crystal
  # require "crake/global"
  #
  # p MANAGER.args
  # # You ran `crystal make.cr -- foo bar -- hello world`:
  # # => ["hello", "world"]
  # ```
  getter args

  # :nodoc:
  setter args

  # Returns the flag which means whether use `spawn`
  # for running a task.
  def spawn?; @spawn end

  # :nodoc:
  def spawn?=(@spawn) end

  # }}}
  # Task running {{{

  # Runs each tasks.
  def run(*targets)
    run targets
  end

  # Runs each tasks.
  def run(targets : Enumerable(String))
    if err = resolve_deps(TopLevelTask.new(targets)).receive
      raise err
    end
  end

  # Resolves the task or the rule named `target`.
  private def resolve_task(namespace, target)
    targets = target.split(":")
    debug "Find target #{target.inspect} in #{namespace}"

    if result = namespace.resolve_task_internal targets[0..-2], targets[-1]
      return result
    end

    if File.exists?(target)
      info "#{target.inspect} is not defined, so use fallback task"
      return {self, FallbackFileTask.new target}
    end

    fatal "#{target.inspect} is not defined"
  end

  # :nodoc:
  alias TimestampGetter = -> Time

  # Resolves dependepcies by topological sort with DFS.
  private def resolve_deps(target,
                           namespace = self,
                           deps_set = Set(String).new,
                           circular_check = Set(String).new) : Channel::Buffered(Exception?)
    Channel(Exception?).new(1).tap do |chan|
      real_proc = -> do
        begin
          full_name = namespace.resolve_name target

          info "#{full_name.inspect} starts"

          debug "#{full_name.inspect}'s dependencies are #{target.deps}"

          # Resolves dependencies

          ts_and_chans = [] of {TimestampGetter, Channel::Buffered(Exception?)}

          target.deps.each do |dep|
            if circular_check.includes? dep
              fatal "#{full_name.inspect} has the circular dependency #{dep.inspect}"
            end

            namespace, dep_task = resolve_task namespace, dep

            unless deps_set.includes? dep
              deps_set.add dep
              circular_check.add dep
              ts_and_chans << {
                TimestampGetter.new{ dep_task.timestamp },
                resolve_deps dep_task, namespace, deps_set, circular_check.dup
              }
              circular_check.delete dep
            end
          end

          # Waits for all tasks

          times = [] of Time

          ts_and_chans.each do |ts_and_chan|
            ts, dep_chan = ts_and_chan
            if err = dep_chan.receive
              raise err
            end
            times << ts.call
          end

          # Checks timestamps

          timestamp = target.timestamp
          debug "#{full_name.inspect}'s timestamp is #{timestamp}"

          flag = times.any?{ |t| t >= timestamp }
          if times.empty?
            flag = timestamp == Time::MaxValue || timestamp == Time::MinValue
          end

          if flag && !target.is_a?(TopLevelTask)
            target.run self
          end

          info "#{full_name.inspect} finished"

          chan.send nil
          chan.close

        rescue err
          chan.send err
          chan.close
        end
      end

      if spawn?
        spawn do
          real_proc.call
        end
      else
        real_proc.call
      end
    end
  end

  # }}}
  # Show tasks {{{

  # Resolves the full name of task on this manager.
  def resolve_name(task)
    task.name
  end

  # Shows tasks managed by self.
  #
  # If `all` flag is `true`, it shows all tasks
  # eihther with or without description. If not,
  # it shows all tasks with description.
  def show_tasks(all = false)
    tasks = all_tasks
    unless tasks.empty?
      longest = tasks.map{ |name, _| name.size }.max
      tasks
        .map{ |name, task| {name, task} }
        .sort_by{ |name_task| name_task[0] as String }
        .each do |name_task|
          name, task = name_task
          next unless task.responds_to? :desc

          if all || !task.desc.empty?
            print "crystal make.cr"
            if name == "default"
              print "    #{" " * longest}"
            else
              print " -- #{name.ljust longest}"
            end
            if task.desc.empty?
              puts
            else
              puts " # #{task.desc}"
            end
          end
        end
    end
  end

  # }}}
  # Logging {{{

  {% for level in Logger::Level.constants %}
    # Logs a message at the `{{ level }}` level.
    delegate {{ level.downcase.id }}, @log
  {% end %}

  # Logs a message at the ERROR level, then raises an error.
  def fatal(message)
    error message
    raise Error.new(message)
  end

  # }}}
end
# vim:fdm=marker:
