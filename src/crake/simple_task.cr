require "./task"

# A simple task for CRake.
class CRake::SimpleTask < CRake::Task
  # Generic task methods.
  module Mixin(I)
    # Properties {{{

    # Returns its name, this is also called target name.
    getter target

    # Same as `target`.
    def name; target end

    # Returns its dependepce task names.
    getter deps

    # }}}
    # Methods as task {{{

    # Run the task on manager.
    def run(manager)
      @action.call I.new self, manager
    end

    # }}}
  end

  include Mixin(Info)

  # Constructor {{{

  # Creates a new task.
  #
  # It isn't registered to `Manager` automatically.
  # If you want this, you can use `Scope#task`.
  def initialize(@target, @desc, @deps, @action); end

  # }}}
  # Properties {{{

  # Returns its full description.
  getter desc

  # Returns its one line description.
  def simple_desc
    desc = desc.lines[0]
    if desc.size > 50
      desc = desc[0...47] + "..."
    end
    desc.strip
  end

  # }}}
  # Methods as task {{{

  # Everytime returns `Time::MaxValue`.
  def timestamp
    Time::MaxValue
  end

  # }}}

  # A task running information.
  struct Info
    module Mixin
    # Constructor {{{

    # :nodoc:
    def initialize(@task, @manager); end

    # }}}
      # Properties {{{

      # Returns the task.
      getter task

      # Returns the manager on which is running.
      getter manager

      # Same as `task.name`.
      def name; task.name end

      # Same as `task.target`.
      def target; task.target end

      # Same as `task.deps`.
      def deps; task.deps end

      # }}}
    end

    include Mixin

    # Properties {{{

      # Same as `task.desc`.
      def desc; task.desc end

      # Same as `task.simple_desc`.
      def simple_desc; task.simple_desc end

    # }}}
  end
end
# vim:fdm=marker:
