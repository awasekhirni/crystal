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
#   "If it walks like a duck and quacks like a duck, it's a duck." Crystal
#   lets you accept ANY object with a matching method — no base class
#   required. This is duck typing via compile-time method lookup.
#
# SETUP:
#   crystal run 018_duck_typing_quacker.cr
# =============================================================================

# No shared base class. Each class independently defines `quack`.
class Duck
  # Return the result of `quack`.
  def quack : String; "Quack!"; end
end

# Concrete class `RobotDuck`.
class RobotDuck
  # Return the result of `quack`.
  def quack : String; "Beep-quack"; end
end

# Concrete class `Person`.
class Person
  # Return the result of `quack`.
  def quack : String; "Squawk (imitating)"; end
end

# The method's parameter type uses Crystal's "responds to" style restriction
# through an untyped (generic) parameter; the compiler enforces the duck
# contract at call sites because we only invoke #quack.
def make_it_quack(quacker) : Nil
  puts quacker.quack
end

# A stronger, checked alternative: define a module and use it in the type
# restriction. This gives the best of both worlds — small contract, explicit.
module Quacker
  # Return the result of `quack`.
  abstract def quack : String
end

# Return the result of `make_it_quack_checked`.
def make_it_quack_checked(q : Quacker) : Nil
  puts q.quack
end

# ---- Demonstration ----------------------------------------------------------
make_it_quack(Duck.new)
make_it_quack(RobotDuck.new)
make_it_quack(Person.new)

# =============================================================================
# EXERCISE 1
#   Add a CarHorn that "quacks" and pass it through make_it_quack.
# SOLUTION 1:
#   class CarHorn
#     def quack : String; "HONK (acceptable quack)"; end
#   end
#   make_it_quack(CarHorn.new)
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Show the failure case: pass an Int32 to make_it_quack.
# SOLUTION 2:
#   # make_it_quack(42)
#   # Compiler error: undefined method 'quack' for Int32.
#   # This is duck typing's superpower: errors happen at compile time,
#   # not at runtime like Ruby/Python.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain the trade-off between untyped duck typing and the explicit
#   Quacker module.
# SOLUTION 3:
#   Untyped duck typing is maximally flexible but the contract is implicit.
#   The Quacker module documents intent, aids autocompletion, and lets
#   downstream APIs express "I need a Quacker" clearly. In Crystal, prefer
#   the explicit module when a contract is meaningful, and fall back to
#   untyped methods when the contract is truly incidental (e.g., generic
#   #to_s-like behavior). Both are resolved at compile time.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
