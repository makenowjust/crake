require "spec"
require "../src/crake/file_task"

action = ->(i : CRake::FileTask::Info){ "action" }

describe CRake::FileTask do
  it "should create a new instance" do
    task = CRake::FileTask.new "name", ["deps"], action
    task.should be_a CRake::FileTask
    task.name.should eq "name"
    task.target.should eq "name"
    task.deps.should eq ["deps"]
  end

  it "should return its timestamp" do
    task = CRake::FileTask.new "not found", ["deps"], action
    (task.timestamp <= Time.now).should be_true

    name = "#{__DIR__}/file/test"
    task = CRake::FileTask.new name, ["deps"], action
    task.timestamp.should eq File.lstat(name).mtime
  end

  it "should run its action" do
    dummy = "dummy"
    not_run = true
    task :: CRake::FileTask
    task = CRake::FileTask.new "name", ["deps"], ->(i : CRake::FileTask::Info) do
      i.task.should be task
      i.name.should eq "name"
      i.target.should eq "name"
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
