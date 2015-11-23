require "./simple_task"

# A file task for CRake.
class CRake::FileTask
  # Generic file task methods.
  module Mixin
    # Methods as task {{{

    # Gets its time stamp.
    #
    # If the file whose name is same as its name
    # exists, it returns this time stamp.
    # If not, it returns `Time::MinValue`.
    #
    # This method is not cached.
    def timestamp : Time
      if File.exists?(name)
        return File.lstat(name).mtime
      else
        return Time::MinValue
      end
    end

    # }}}
  end

  include Mixin
  include SimpleTask::Mixin(Info)

  # Constructor {{{

  # Creates a new file task.
  #
  # It isn't registered to `Manager` automatically.
  # If you want this, you can use `Scope#file`.
  def initialize(@target, @deps, @action); end

  # }}}

  struct Info
    include SimpleTask::Info::Mixin
  end
end
# vim:fdm=marker:
