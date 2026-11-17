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
#   A shop's discount rules shouldn't require cutting the register open every
#   time marketing invents a new sale. Open/Closed Principle (OCP): classes
#   should be OPEN for extension but CLOSED for modification. Add new
#   discounts without editing existing ones.
#
# SETUP:
#   crystal run 011_solid_ocp_discount.cr
# =============================================================================

# --- Bad (OCP violator) ------------------------------------------------------
# Adding "black friday" would mean editing this method — a modification,
# not an extension.
#
#   def discount(type : Symbol, amount : Float64)
#     case type
#     when :none    then 0.0
#     when :percent then amount  0.10
#     when :flat    then 5.0
#     end
#   end

# --- Good (OCP-compliant) ----------------------------------------------------
# Each discount is a self-contained object; the register never changes.
module Discount
  # Apply the operation and return the result.
  abstract def apply(amount : Float64) : Float64
end

# Concrete class `NoDiscount`.
class NoDiscount
  include Discount
  # Apply the operation and return the result.
  def apply(amount : Float64) : Float64; amount; end
end

# Concrete class `PercentDiscount`.
class PercentDiscount
  include Discount
  def initialize(@pct : Float64); end
  # Apply the operation and return the result.
  def apply(amount : Float64) : Float64
    amount * (1.0 - @pct)
  end
end

# Concrete class `FlatDiscount`.
class FlatDiscount
  include Discount
  def initialize(@off : Float64); end
  # Apply the operation and return the result.
  def apply(amount : Float64) : Float64
    Math.max(0.0, amount - @off)
  end
end

# Concrete class `Register`.
class Register
  def initialize(@discount : Discount = NoDiscount.new); end
  # Compute and return the total.
  def total(amount : Float64) : Float64; @discount.apply(amount); end
end

# ---- Demonstration ----------------------------------------------------------
puts Register.new(PercentDiscount.new(0.10)).total(100.0)  # 90.0
puts Register.new(FlatDiscount.new(15.0)).total(100.0)     # 85.0
puts Register.new.total(100.0)                              # 100.0

# =============================================================================
# EXERCISE 1
#   Add a BlackFridayDiscount (50% off) WITHOUT modifying any existing class.
# SOLUTION 1:
#   class BlackFridayDiscount
#     include Discount
#     def apply(amount : Float64) : Float64; amount  0.5; end
#   end
#   puts Register.new(BlackFridayDiscount.new).total(100.0)  # 50.0
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Combine two discounts via a CompositeDiscount.
# SOLUTION 2:
#   class CompositeDiscount
#     include Discount
#     def initialize(@first : Discount, @second : Discount); end
#     def apply(amount : Float64) : Float64
#       @second.apply(@first.apply(amount))
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a "buy two, get 10% off" that needs quantity — extend the contract
#   with a new interface rather than editing Discount.
# SOLUTION 3:
#   module QuantityDiscount
#     abstract def apply_qty(amount : Float64, qty : Int32) : Float64
#   end
#   Register gets a new overload `total(amount, qty)` that dispatches only
#   to QuantityDiscount-capable objects. Existing code stays untouched.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
