@[Link(ldflags: "#{__DIR__}/lib/hello.o")]
lib LibHello
  fun hello : Void
end

LibHello.hello
