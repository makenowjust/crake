require "spec"
require "../src/crake"

describe CRake do
  it "should run" do
    flag = 0
    CRake::DSL.task "task1", deps: %w(task2) do
      flag += 1
    end
    CRake::DSL.task "task2" do
      flag += 1
    end
    CRake.run %w(task1)
    flag.should eq 2
  end
end
