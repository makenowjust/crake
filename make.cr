require "./src/global"

task "default # run specs and examples", %w(spec example)

# spec {{{

spec_files = Dir.cd("spec"){ Dir["*_spec.cr"] }
  .map{ |s| s.gsub(/_spec\.cr\z/, "") }
  .map{ |s| "spec:#{s}" }

task "spec # run specs", deps: spec_files

namespace :spec do
  rule /.*/ do |i|
    sh "crystal spec/#{i.target}_spec.cr"
  end
end

# }}}
# example {{{

example_files = Dir.cd("example"){ Dir["*"] }
  .map{ |s| "example:#{s}" }

task "example # run examples", deps: example_files

namespace :example do
  rule /.*/ do |i|
    sh "cd example/#{i.target} && shards install"
    sh "cd example/#{i.target} && crystal make.cr -- clean && crystal make.cr"
  end
end
# }}}
# vim:fdm=marker:
