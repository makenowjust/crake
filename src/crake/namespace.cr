require "./file_task"
require "./namespace"
require "./rule"
require "./simple_task"
require "./task"

class CRake::Namespace
  module Mixin
    # Name space, task and rule management {{{

    {% for type in %w(namespace task) %}
      {% type = type.id %}

      # Tries to find the {{ type }}.
      def find_{{ type }}(target) : {{ type.camelcase }}?
        @{{ type }}s[target]?
      end

      # Adds a {{ type }}.
      def add_{{ type }}({{ type }})
        @{{ type }}s[{{ type }}.target] = {{ type }} as {{ type.camelcase }}
      end
    {% end %}

    # Tries to find the rule.
    def find_rule(target) : Rule::Task?
      @rules.each do |rule|
        if task = rule.create_task target
          return task
        end
      end
      nil
    end

    # Adds a rule.
    def add_rule(rule)
      @rules << rule
    end

    # Returns all tasks.
    #
    # It finds sub-namespaces.
    def all_tasks
      tasks = {} of String => Task
      @tasks.each do |target, task|
        tasks[resolve_name(task)] = task
      end
      @namespaces.each do |target, namespace|
        tasks.merge! namespace.all_tasks
      end
      tasks
    end

    # }}}
    # Task name resolver {{{

    # :nodoc:
    def resolve_task_internal(ns_list : Array(String), target : String)
      namespace = self

      ns_list.each do |target|
        unless namespace = namespace.find_namespace target
          break
        end
      end

      if namespace
        if task = namespace.find_task(target) || namespace.find_rule(target)
          return {namespace, task}
        end
      end

      if parent = @parent
        parent.resolve_task_internal ns_list, target
      else
        nil
      end
    end

    # }}}
    # Tasks {{{

    # Defines a task without a block.
    #
    # ```crystal
    # task "default", deps: %w(hello world)
    # ```
    def task(targetdesc, deps = [] of String)
      task targetdesc, deps  do |r|
        # nop
      end
    end

    # Defines a task.
    #
    # ```crystal
    # task "name  # description", deps: %w(deps1 deps2) do |r|
    #   # your task here
    # end
    # ```
    def task(targetdesc, deps = [] of String, &action : SimpleTask::Info ->)
      targetdesc = targetdesc.to_s.split("#", 2)
      target = targetdesc[0].strip
      desc = targetdesc[1]?.try(&.strip) || ""

      SimpleTask.new(target, desc, deps, action).tap do |t|
        add_task t
      end
    end

    # }}}
    # Files {{{

    # Defines a file task without a block.
    def file(target, deps = [] of String)
      file target, deps do
        # nop
      end
    end

    # Defines a file task.
    #
    # ```crystal
    # file "hello", deps: %w(hello.o) do |r|
    #   sh "#{CC} -o #{r.name} #{r.deps.join " "}"
    # end
    # ```
    def file(target, deps = [] of String, &action : FileTask::Info ->)
      FileTask.new(target.to_s, deps, action).tap do |task|
        add_task task
      end
    end

    # }}}
    # Rules {{{

    # Defines a rule without a block.
    def rule(rule, deps = [] of String)
      rule rule, deps do |r|
        # nop
      end
    end

    # Defines a rule.
    #
    # ```crystal
    # rule(/\.o$/, deps: ext ".c") do |r|
    #   sh "#{CC} -c -o #{r.name} #{r.deps[0]}"
    # end
    # ```
    def rule(rule, deps = [] of String, &action : Rule::Task::Info ->)
      Rule.new(rule, deps, action).tap do |rule|
        add_rule rule
      end
    end

    # }}}
    # Name space {{{

    # Define a neme space.
    #
    # ```crystal
    # namespace "hello" do
    #   # your tasks here.
    # end
    # ```
    def namespace(target, &block)
      Namespace.new(target.to_s, self).tap do |namespace|
        with namespace yield namespace
        add_namespace namespace
      end
    end

    # }}}
  end

  include Mixin

  # Constructor {{{

  def initialize(@target, @parent)
    @namespaces = {} of String => Namespace
    @tasks = {} of String => Task
    @rules = [] of Rule

    if (parent = @parent).responds_to? :full
      @full = parent.full + ":" + @target
    else
      @full = @target
    end
  end

  # }}}
  # Properties {{{

  # Returns this full name.
  getter full

  # Returns this name which is also called target name.
  getter target

  # Same as `target`
  def name; target end

  # }}}
  # Utilities for tasks {{{

  # Resolves the full name of task on this namespace.
  def resolve_name(task)
    full + ":" + task.name
  end

  # }}}
end
# vim:fdm=marker:
