# This file redefine the `main` function which is
# entry point of `make.cr`, but it runs after bare
# statements. It processes command line arguments
# and runs tasks.

require "./run"

redefine_main do |main|
  {{ main }}

  begin
    CRake.run
  rescue CRake::Error
    exit 1
  end
end
