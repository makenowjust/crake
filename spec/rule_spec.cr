require "spec"
require "../src/crake/rule"

action = ->(i : CRake::Rule::Task::Info){ "action" }

describe CRake::Rule do
  it "should create a new instance" do
    rule = CRake::Rule.new /rule/, ["deps"], action
    rule.should be_a CRake::Rule
    rule.pattern.should eq /rule/
  end

  it "should create a new task" do
    rule = CRake::Rule.new /rule/, ["deps"], action
    rule.create_task("not match").should be_nil
    task = rule.create_task("rule").not_nil!
    task.should be_a CRake::Rule::Task
    task.rule.should be rule
    task.name.should eq "rule"
    task.target.should eq "rule"
    task.deps.should eq ["deps"]
    task.match[0].should eq "rule"

    rule = CRake::Rule.new /rule/, ["deps", ->(s : String){ [s, s] }, {"task"}], action
    task = rule.create_task("rule").not_nil!
    task.should be_a CRake::Rule::Task
    task.deps.should eq ["deps", "rule", "rule", "task"]
  end

  it "should run its action by created task" do
    dummy = "dummy"
    not_run = true
    rule :: CRake::Rule
    task :: CRake::Rule::Task
    rule = CRake::Rule.new /rule/, ["deps"], ->(i : CRake::Rule::Task::Info) do
      i.rule.should be rule
      i.task.should be task
      i.pattern.should eq /rule/
      i.name.should eq "rule"
      i.target.should eq "rule"
      i.deps.should eq ["deps"]
      i.match[0].should eq "rule"
      i.manager.should be dummy
      not_run = false
    end
    task = rule.create_task("rule").not_nil!
    task.run dummy
    if not_run
      fail "not run its action"
    end
  end
end
