# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:
#   If your code says "any Bird can fly", then a Penguin that claims to be
#   a Bird should not crash when someone calls fly. Liskov Substitution
#   Principle (LSP): subclasses must be usable anywhere their parent is,
#   without surprises.
#
# SETUP:
#   crystal run 013_solid_lsp_birds.cr
# =============================================================================

# --- Bad: Penguin breaks the "Bird fly" contract ---------------------------
#
#   class Bird; def fly; "flying"; end; end
#   class Penguin < Bird
#     def fly; raise "Penguins can't fly"; end   # LSP violation
#   end

# --- Good: split the abstraction -------------------------------------------
# "Bird" is not the right level of abstraction. Introduce "Flying" as a
# separate capability, and let a Bird exist without it.
class Bird
  getter name : String
  def initialize(@name : String); end
  # Return the result of `describe`.
  def describe : String; "#{@name} the bird"; end
end

# Module `Flying`.
module Flying
  # Return the result of `fly`.
  abstract def fly : String
end

# Concrete class `Sparrow` -- extends Bird.
class Sparrow < Bird
  include Flying
  # Return the result of `fly`.
  def fly : String; "#{@name} flutters up"; end
end

# Concrete class `Penguin` -- extends Bird.
class Penguin < Bird
  # No Flying mixed in — callers can't accidentally fly a penguin.
  def swim : String; "#{@name} swims"; end
end

# Client only requires Flying where flying is needed — substitution safe.
def send_flying(birds : Array(Flying))
  birds.each { |b| puts b.fly }
end

# ---- Demonstration ----------------------------------------------------------
birds : Array(Bird) = [Sparrow.new("Tweety"), Penguin.new("Pingu")] of Bird
birds.each { |b| puts b.describe }
send_flying([Sparrow.new("Sunny")] of Flying)

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
