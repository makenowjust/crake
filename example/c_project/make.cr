require "../../src/crake/global"

CC = ENV.fetch "CC", "gcc"

task "default", deps: %w(run)

task "run # run app", deps: %w(build) do
  sh "./hello"
end

task "build # build app", deps: %w(hello)

task "clean # remove build files" do
  sh "rm -f *.o"
  sh "rm -f hello"
end

file("hello", deps: Dir["*.c"].map(&ext(".o")).flatten) do |i|
  sh "#{CC} -o #{i.name} #{i.deps.join " "}"
end

rule(/\.o\z/, deps: ext(".c")) do |i|
  sh "#{CC} -c -o #{i.name} #{i.deps[0]}"
end

rule /\.c\z/, deps: ->(name : String) do
  headers = [] of String
  File.each_line(name) do |line|
    if line =~ /#include\s+"([^"]+)"/
      headers << $1
    end
  end
  headers
end
