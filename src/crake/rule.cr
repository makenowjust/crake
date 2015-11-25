require "./file_task"
require "./simple_task"

# A rule of CRake
class CRake::Rule
  # Constructor {{{

  # Create a new rule.
  #
  # It isn't registered to `Manager` automatically.
  # If you want this, you can use `Scope#rule`.
  def initialize(@pattern, @deps, @action); end

  # }}}
  # Properties {{{

  # Returns its pattern.
  getter pattern

  # }}}
  # Task creator {{{

  # Try to create the task from self and name.
  #
  # If it returns `nil`, it means not to match
  # pattern of the rule with name.
  def create_task(target)
    if match = pattern.match(target)
      return Task.new target, match, self, expand_deps(target), @action
    end

    nil
  end

  # Expand dependencies.
  private def expand_deps(target) : Array(String)
    deps = [] of String
    expand_deps(target, @deps){ |dep| deps << dep }
    deps
  end

  # Expand dependencies.
  private def expand_deps(target, deps, &block : String ->)
    if deps.is_a?(String)
      yield deps
    elsif deps.responds_to?(:each)
      deps.each { |dep| expand_deps target, dep, &block }
    else
      expand_deps target, deps.call(target), &block
    end
  end

  # }}}

  # A task created by the rule.
  class Task < CRake::Task
    include SimpleTask::Mixin(Info)
    include FileTask::Mixin

    # Constructor {{{

    # :nodoc:
    def initialize(@target, @match, @rule, @deps, @action); end

    # }}}
    # Properties {{{

    # Returns `Regex::MatchData` which wes match `pattern` with `target` when `Rule#create_task`.
    getter match

    # Returns the rule which generated self.
    getter rule

    # Same as `rule.pattern`.
    def pattern; rule.pattern end

    # }}}

    # A task created by the rule information.
    struct Info
      include SimpleTask::Info::Mixin

      # Properties {{{

      # Same as `task.match`.
      def match; task.match end

      # Same as `task.rule`.
      def rule; task.rule end

      # Same as `task.pattern`.
      def pattern; task.pattern end

      # }}}
    end
  end
end
# vim:fdm=marker:
