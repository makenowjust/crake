#!/usr/bin/env crystal

require "crake/global"

task "default", %w(run)

task "run", %w(build) do
  sh "./bin/hello"
end

task "build", %w(bin/hello)

file "bin/hello", %w(src/hello.cr src/lib/hello.o) do |i|
  sh "crystal build -o #{i.target} #{i.deps[0]}"
end

rule(/\.o\z/, ext(".c")) do |i|
  sh "gcc -c -o #{i.target} #{i.deps[0]}"
end

task "clean" do
  sh "rm -f bin/hello src/lib/*.o"
end
