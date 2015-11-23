require "./file_task"
require "./simple_task"

module CRake
  alias Task = FileTask|SimpleTask
end
