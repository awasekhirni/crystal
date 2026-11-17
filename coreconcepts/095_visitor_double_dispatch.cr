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
#   Normal method dispatch is "one-dimensional": which method gets called
#   depends on the receiver's type. Visitor makes it two-dimensional: which
#   method gets called depends on BOTH the receiver's type AND the visitor's
#   type. Hence "double dispatch."
#
# SETUP:
#   crystal run 095_visitor_double_dispatch.cr
# =============================================================================

# --- Element -------------------------------------------------------------
module Animal
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  abstract def accept(v : Visitor) : String
end

# Concrete class `Dog`.
class Dog
  include Animal
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  def accept(v : Visitor) : String; v.visit_dog(self); end
end

# Concrete class `Cat`.
class Cat
  include Animal
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  def accept(v : Visitor) : String; v.visit_cat(self); end
end

# --- Visitor -------------------------------------------------------------
module Visitor
  # Visit a Dog; return the action String.
  abstract def visit_dog(d : Dog) : String
  # Visit a Cat; return the action String.
  abstract def visit_cat(c : Cat) : String
end

# Concrete class `SoundVisitor`.
class SoundVisitor
  include Visitor
  # Visit a Dog; return the action String.
  def visit_dog(_animal : Dog) : String; "woof"; end
  # Visit a Cat; return the action String.
  def visit_cat(_animal : Cat) : String; "meow"; end
end

# Concrete class `FeedVisitor`.
class FeedVisitor
  include Visitor
  # Visit a Dog; return the action String.
  def visit_dog(_animal : Dog) : String; "feed kibble"; end
  # Visit a Cat; return the action String.
  def visit_cat(_animal : Cat) : String; "feed fish"; end
end

# --- Prove the two-dispatch behavior with a demo -------------------------
def describe(a : Animal, v : Visitor) : String
  # 1) Dispatch on `a` to pick `accept`: Dog or Cat.
  # 2) `accept` calls v.visit_x: dispatch on `v` to pick Sound vs Feed.
  # The pair (a, v) determines the method.
  a.accept(v)
end

# ---- Demonstration ----------------------------------------------------------
animals : Array(Animal) = [Dog.new, Cat.new] of Animal
visitors : Array(Visitor) = [SoundVisitor.new, FeedVisitor.new] of Visitor
animals.each do |a|
  visitors.each do |v|
    puts "#{a.class}/#{v.class}: #{describe(a, v)}"
  end
end

# =============================================================================
# EXERCISE 1
#   Add a "PlayVisitor" and show 2×3 = 6 combinations.
# SOLUTION 1:
#   class PlayVisitor; include Visitor
#     def visit_dog(_); "fetch"; end
#     def visit_cat(_); "laser pointer"; end
#   end
#   visitors << PlayVisitor.new
# =============================================================================

# =============================================================================
# EXERCISE 2
#   What would you need to do WITHOUT Visitor to get the same result?
# SOLUTION 2:
#   A nested case:
#     case animal
#     when Dog then case visitor when Sound ... when Feed ...
#     when Cat then case visitor when Sound ... when Feed ...
#   The number of combinations grows as |animals| × |visitors| — and each
#   new animal or visitor forces editing every case. Visitor makes each
#   axis independent (add a class).
# =============================================================================

# =============================================================================
# EXERCISE 3
#   In a statically-typed language like Crystal, why doesn't plain overloading
#   solve this automatically?
# SOLUTION 3:
#   Method overloading is resolved at compile time using static types. In
#   `describe(a : Animal, v : Visitor)`, a is statically Animal, so the
#   compiler picks Animal#accept regardless of runtime type. Visitor turns
#   runtime-type information into source structure via `accept` — the
#   virtual call carries runtime dispatch through `self` (typed as the
#   concrete element).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
