# This file is the entry point of CRake.
# It exports `CRake::Scope` methods to global scope and redefine
# `main` function.

require "./crake/dsl"
require "./crake/main"

include CRake::DSL
