require "crake/global"

task :default, %w(hello)

task "hello # say hello" do
  puts "Hello, CRake World!"
end

task :clean
