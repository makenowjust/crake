require "spec"
require "../src/crake/simple_task"

$action = ->(i : CRake::SimpleTask::Info){ "action" }

describe CRake::SimpleTask do
  it "should create a new instance" do
    task = CRake::SimpleTask.new "name", "desc", ["deps"], $action
    task.should be_a CRake::SimpleTask
    task.name.should eq "name"
    task.target.should eq "name"
    task.desc.should eq "desc"
    task.deps.should eq ["deps"]
  end

  it "should return its timestamp" do
    task = CRake::SimpleTask.new "name", "desc", ["deps"], $action
    (task.timestamp >= Time.now).should be_true
  end

  it "should return its simple description" do
    desc = "x" * 55
    task = CRake::SimpleTask.new "name", desc, ["deps"], $action
    task.desc.should eq desc
    task.simple_desc.should eq "#{"x" * 47}..."
    desc = "#{"x" * 30}\n#{"x" * 30}"
    task = CRake::SimpleTask.new "name", desc, ["deps"], $action
   task.desc.should eq desc
    task.simple_desc.should eq "#{"x" * 30}"
  end

  it "should run its action" do
    dummy = "dummy"
    not_run = true
    task :: CRake::SimpleTask
    task = CRake::SimpleTask.new "name", "desc", ["deps"], ->(i : CRake::SimpleTask::Info) do
      i.task.should be task
      i.name.should eq "name"
      i.target.should eq "name"
      i.desc.should eq "desc"
      i.simple_desc.should eq "desc"
      i.deps.should eq ["deps"]
      i.manager.should be dummy
      not_run = false
    end
    task.run dummy
    if not_run
      fail "not run its action"
    end
  end
end
