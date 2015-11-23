require "spec"
require "../src/crake/namespace"

describe CRake::Namespace do
  it "should create a new instance" do
    ns = CRake::Namespace.new "ns", nil
    ns.should be_a CRake::Namespace
    ns.name.should eq "ns"
    ns.target.should eq "ns"
    ns.full.should eq "ns"
  end

  it "should manage tasks, files, rules and namespaces" do
    ns = CRake::Namespace.new "ns", nil

    task = CRake::SimpleTask.new "task", "desc", ["deps"], ->(i : CRake::SimpleTask::Info){ "action" }
    ns.add_task task
    ns.find_task("not found").should be_nil
    ns.find_task("task").should be task
    task = CRake::FileTask.new "file", ["deps"], ->(i : CRake::FileTask::Info){ "action" }
    ns.add_task task
    ns.find_task("file").should be task

    rule = CRake::Rule.new /rule/, ["deps"], ->(i : CRake::Rule::Task::Info){ "action" }
    ns.add_rule rule
    ns.find_rule("not found").should be_nil
    ns.find_rule("rule").not_nil!.rule.should be rule

    namespace = CRake::Namespace.new "namespace", ns
    namespace.full.should eq "ns:namespace"
    ns.add_namespace namespace
    ns.find_namespace("not found").should be_nil
    ns.find_namespace("namespace").should be namespace
  end
end
