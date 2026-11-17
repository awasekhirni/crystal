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
#   Base coffee + milk + sugar + whip. Each add-on "wraps" the previous drink
#   and adds to the description and price. Decorator = wrap an object in
#   another object that has the same interface, layering behavior.
#
# SETUP:
#   crystal run 051_decorator_coffee.cr
# =============================================================================

# Module `Beverage`.
module Beverage
  # Return the result of `description`.
  abstract def description : String
  # Return the result of `cost`.
  abstract def cost : Float64
end

# Concrete class `Espresso`.
class Espresso
  include Beverage
  # Return the result of `description`.
  def description : String; "Espresso"; end
  # Return the result of `cost`.
  def cost : Float64; 2.0; end
end

# The abstract decorator holds a Beverage and delegates. Concrete decorators
# add to description/cost.
abstract class BeverageDecorator
  include Beverage
  def initialize(@beverage : Beverage); end
  # Return the result of `description`.
  def description : String; @beverage.description; end
  # Return the result of `cost`.
  def cost : Float64; @beverage.cost; end
end

# Concrete class `Milk` -- extends BeverageDecorator.
class Milk < BeverageDecorator
  # Return the result of `description`.
  def description : String; "#{super}, Milk"; end
  # Return the result of `cost`.
  def cost : Float64; super + 0.5; end
end

# Concrete class `Sugar` -- extends BeverageDecorator.
class Sugar < BeverageDecorator
  # Return the result of `description`.
  def description : String; "#{super}, Sugar"; end
  # Return the result of `cost`.
  def cost : Float64; super + 0.25; end
end

# Concrete class `Whip` -- extends BeverageDecorator.
class Whip < BeverageDecorator
  # Return the result of `description`.
  def description : String; "#{super}, Whip"; end
  # Return the result of `cost`.
  def cost : Float64; super + 0.75; end
end

# ---- Demonstration ----------------------------------------------------------
drink = Whip.new(Milk.new(Sugar.new(Espresso.new)))
puts drink.description   # Espresso, Sugar, Milk, Whip
puts drink.cost          # 3.5

# =============================================================================
# EXERCISE 1
#   Add a "SoyMilk" decorator and compute the total for an espresso with
#   soy + sugar.
# SOLUTION 1:
#   class SoyMilk < BeverageDecorator
#     def description; "#{super}, Soy"; end
#     def cost; super + 0.6; end
#   end
#   d = Sugar.new(SoyMilk.new(Espresso.new))
#   puts d.cost   # 2 + 0.6 + 0.25 = 2.85
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "size" concept (S/M/L) that multiplies cost. Where should it live?
# SOLUTION 2:
#   Introduce a SizeDecorator (or a size attribute on Espresso, but that
#   requires touching the base class — anti-OCP). SizeDecorator wraps any
#   Beverage and multiplies cost by a factor; description appends ", L".
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare Decorator with Inheritance: when is each appropriate?
# SOLUTION 3:
#   Inheritance: fixed combinations known at compile time; want is-a. Fast
#   dispatch; each variant = one class. Decorator: open-ended combinations
#   known at runtime; each decorator can wrap any Beverage. The number of
#   classes grows linearly (2^n combinations without it). Decorator shines
#   when combinations are user-driven and dynamic.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
