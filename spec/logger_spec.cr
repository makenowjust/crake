require "spec"
require "../src/crake/logger"

def logger
  io = MemoryIO.new
  yield CRake::Logger.new io
  io.to_s
end

describe CRake::Logger do
  it "is the WARN level" do
    logger do |log|
      log.level.should eq CRake::Logger::Level::WARN
    end
  end

  it "should log a message" do
    logger { |log| log.warn("message") }.empty?.should be_false
    logger { |log| log.error("message") }.empty?.should be_false

    logger { |log|
      log.level = CRake::Logger::Level::DEBUG
      log.debug("message")
    }.empty?.should be_false
    logger { |log|
      log.level = CRake::Logger::Level::DEBUG
      log.info("message")
    }.empty?.should be_false
  end

  it "shouldn't log a message" do
    logger { |log| log.debug("message") }.empty?.should be_true
    logger { |log| log.info("message") }.empty?.should be_true

    logger { |log|
      log.level = CRake::Logger::Level::ERROR
      log.warn("message")
    }.empty?.should be_true
  end
end
