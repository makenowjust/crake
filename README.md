# CRake

A __CRystal mAKE__ library.

[![](https://img.shields.io/travis/MakeNowJust/crake.svg?style=flat-square)](https://travis-ci.org/MakeNowJust/crake)
[![docrystal.org](https://img.shields.io/badge/docrystal-ref-866BA6.svg?style=flat-square)](http://docrystal.org/github.com/MakeNowJust/crake)

## Just a Library

It is not a tool, just a __library__. It does not provide a CLI tool like `crake`.  You do learn the library only, not need to learn some tool except for `crystal` command because it is the library of [Crystal](http://crystal-lang.org/).

I believe this approach is better than another build command.  It makes your build script powerful and flexible.  And, it makes so possible to integrate another library.  Simple is the best.

This library is inspired by [Rake](https://github.com/ruby/rake), [gulp](http://gulpjs.com/), [tape](https://github.com/substack/tape) and more. Thanks those libraries and tools ;)


## Features

  - Looks like Rake.  There are `task`, `file`, `rule` and `namespace` in this library.
  - Use the syntax of Crystal. It's smart.
  - Support concurrent build by default.


## Installation

Add this to your application's `shard.yml`:

```yaml
development_dependencies:
  crake:
    github: MakeNowJust/crake
```


## Usage

Put this code into `make.cr`:


```crystal
require "crake/global"

task "hello # say hello" do
  puts "Hello, CRake World!"
end
```

then you can run:

```console
$ crystal make.cr -- hello
Hello, CRake World!
```

If you want more information, you can run such a command:

```console
$ crystal make.cr -- hello -v
 INFO   (2015-11-20 12:34:20 +0000) ~~> "##toplevel##" starts
 INFO   (2015-11-20 12:34:20 +0000) ~~> "hello" starts
Hello, CRake World!
 INFO   (2015-11-20 12:34:20 +0000) ~~> "hello" finished
 INFO   (2015-11-20 12:34:20 +0000) ~~> "##toplevel##" finished
```

and you can see `example/` directory.


## Development

```console
$ crystal make.cr -- spec
```


## TODO

  - [x] Add `task`, `rule`, `file` and `namespace`.
  - [x] Support concurrent build (default.)
  - [x] Support colored output (default.)
  - [ ] Write more documents.
  - [ ] Add more specs and examples.


## Contributing

1. Fork it ([https://github.com/MakeNowJust/crake/fork](https://github.com/MakeNowJust/crake/fork))
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Contributors

- [@MakeNowJust](https://github.com/MakeNowJust) TSUYUSATO Kitsune - creator, maintainer
