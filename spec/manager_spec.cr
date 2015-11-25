require "spec"
require "../src/crake/manager"

class Object
  # monkey patch (it may be a bug.)
  def !~(other)
    !(self =~ other)
  end
end

def manager
  io = MemoryIO.new
  yield CRake::Manager.new io
  io.to_s
end

describe CRake::Manager do
  it "should create a new instance" do
    manager = CRake::Manager.new
    manager.should be_a CRake::Manager
    manager.log.should be_a CRake::Logger
  end

  it "should log messages" do
    manager{ |m| m.debug "debug" }.empty?.should be_true
    manager{ |m| m.info "info" }.empty?.should be_true
    manager{ |m| m.warn "warn" }.empty?.should be_false
    manager{ |m| m.error "error" }.empty?.should be_false

    expect_raises CRake::Error, /##fatal##/ do
      manager{ |m| m.fatal "##fatal##" }
    end
  end

  it "should manage tasks, files, rules and namespaces" do
    manager = CRake::Manager.new

    task = CRake::SimpleTask.new "task", "desc", ["deps"], ->(i : CRake::SimpleTask::Info){ "action" }
    manager.add_task task
    manager.find_task("not found").should be_nil
    manager.find_task("task").should be task
    task = CRake::FileTask.new "file", ["deps"], ->(i : CRake::FileTask::Info){ "action" }
    manager.add_task task
    manager.find_task("file").should be task

    rule = CRake::Rule.new /rule/, ["deps"], ->(i : CRake::Rule::Task::Info){ "action" }
    manager.add_rule rule
    manager.find_rule("not found").should be_nil
    manager.find_rule("rule").not_nil!.rule.should be rule

    namespace = CRake::Namespace.new "namespace", manager
    manager.add_namespace namespace
    manager.find_namespace("not found").should be_nil
    manager.find_namespace("namespace").should be namespace
  end

  it "should run tasks" do
    s1 = manager do |m|
      task = CRake::SimpleTask.new "task", "desc", %w(), ->(i : CRake::SimpleTask::Info) do
        i.manager.error "##test##"
      end
      m.add_task task
      m.run "task"
    end
    (s1 =~ /##test##/).should be_truthy

    s2 = manager do |m|
      task1 = CRake::SimpleTask.new "task1", "desc", %w(task2), ->(i : CRake::SimpleTask::Info) do
        i.manager.error "##test1##"
      end
      task2 = CRake::SimpleTask.new "task2", "desc", %w(), ->(i : CRake::SimpleTask::Info) do
        i.manager.error "##test2##"
      end
      m.add_task task1
      m.add_task task2
      m.run "task1"
    end
    (s2 =~ /##test2##.+##test1##/m).should be_truthy

    expect_raises CRake::Error, /"task" is not defined/ do
      manager do |m|
        m.run "task"
      end
    end

    expect_raises CRake::Error, /"task" has the circular dependency "task"/ do
      manager do |m|
        task = CRake::SimpleTask.new "task", "desc", %w(task), ->(i : CRake::SimpleTask::Info) do
          i.manager.error "##test##"
        end
        m.add_task task
        m.run "task"
      end
    end
  end

  it "should run files" do
    s1 = manager do |m|
      file1 = CRake::FileTask.new "file1", %w(), ->(i : CRake::FileTask::Info) do
        i.manager.error "##test##"
      end
      m.add_task file1
      m.run "file1"
    end
    (s1 =~ /##test##/).should be_truthy

    s2 = manager do |m|
      file1 = CRake::FileTask.new "file1", %w(file2), ->(i : CRake::FileTask::Info) do
        i.manager.error "##test1##"
      end
      file2 = CRake::FileTask.new "file2", %w(), ->(i : CRake::FileTask::Info) do
        i.manager.error "##test2##"
      end
      m.add_task file1
      m.add_task file2
      m.run "file1"
    end
    (s2 =~ /##test2##.+##test1##/m).should be_truthy

    s3 = manager do |m|
      file1 = CRake::FileTask.new "file1", ["#{__DIR__}/file/test"], ->(i : CRake::FileTask::Info) do
        i.manager.error "##file1##"
      end
      file2 = CRake::FileTask.new "#{__DIR__}/file/test", %w(), ->(i : CRake::FileTask::Info) do
        i.manager.error "##file2##"
      end
      m.add_task file1
      m.add_task file2
      m.run "file1"
    end
    (s3 =~ /##file1##/).should be_truthy
    (/##file2##/ !~ s3).should be_truthy
  end

  it "should run rules" do
    s1 = manager do |m|
      rule1 = CRake::Rule.new /rule1/, %w(), ->(i : CRake::Rule::Task::Info) do
        i.manager.error "##rule1##"
      end
      m.add_rule rule1
      m.run "rule1"
    end
    (s1 =~ /##rule1##/).should be_truthy
  end

  it "should run namespaces" do
    s1 = manager do |m|
      ns = CRake::Namespace.new "ns", m
      m.add_namespace ns
      task = CRake::SimpleTask.new "task", "desc", %w(), ->(i : CRake::SimpleTask::Info) do
        i.manager.error "##ns##"
      end
      ns.add_task task
      m.run "ns:task"
    end
    (s1 =~ /##ns##/).should be_truthy
  end

  it "should wait tasks" do
    s1 = manager do |m|
      task1 = CRake::SimpleTask.new "task1", "desc", %w(), ->(i : CRake::SimpleTask::Info) do
        raise "##error##"
      end
      task2 = CRake::SimpleTask.new "task2", "desc", %w(), ->(i : CRake::SimpleTask::Info) do
        sleep 0
        i.manager.error "##task2##"
      end

      m.add_task task1
      m.add_task task2

      expect_raises Exception, "##error##" do
        m.run "task1", "task2"
      end
    end
    (s1 =~ /##task2##/).should be_truthy
  end
end
