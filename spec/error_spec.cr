require "spec"
require "../src/crake/error"

describe CRake::Error do
  it "can do to be raised" do
    flag = false
    error = CRake::Error.new("test")
    begin
      raise error
    rescue caught : CRake::Error
      flag = true
      caught.should be error
    end
    flag.should be_true
  end
end
