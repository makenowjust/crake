# This file is the entry point of CRake.
# It exports `CRake::Scope` methods to global scope and redefine
# `main` function.

require "./dsl"
require "./main"

include CRake::DSL
