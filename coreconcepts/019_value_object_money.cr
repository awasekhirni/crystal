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
#   A five-dollar bill equals another five-dollar bill. It doesn't matter
#   which physical bill you have — the value is what counts. A value object
#   is defined by its data, is immutable, and compares by value.
#
# SETUP:
#   crystal run 019_value_object_money.cr
# =============================================================================

# Immutable value object: no setters, private constructor-level invariants,
# equality by currency + minor units.
class Money
  getter amount_cents : Int64
  getter currency : String

  def initialize(@amount_cents : Int64, @currency : String)
    raise ArgumentError.new("currency cannot be empty") if @currency.empty?
  end

  # Factory for cleaner call sites.
  def self.of(dollars : Float64, currency : String = "USD") : Money
    new((dollars * 100).round.to_i64, currency)
  end

  # Arithmetic returns new instances (immutability).
  def +(other : Money) : Money
    check_same_currency!(other)
    Money.new(@amount_cents + other.amount_cents, @currency)
  end

  def -(other : Money) : Money
    check_same_currency!(other)
    Money.new(@amount_cents - other.amount_cents, @currency)
  end

  # Return a new Money scaled by `factor`.
  def times(factor : Int32) : Money
    Money.new(@amount_cents * factor, @currency)
  end

  # Operator overload so Money value objects compose idiomatically in
  # Crystal (`a * 3` instead of `a.times(3)`).  Delegates to `times`.
  def *(factor : Int32) : Money
    times(factor)
  end

  # Value equality.
  def ==(other : Money) : Bool
    @amount_cents == other.amount_cents && @currency == other.currency
  end

  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil
    io << "#{@currency} #{"%.2f" % (@amount_cents / 100.0)}"
  end

  private def check_same_currency!(other : Money)
    raise ArgumentError.new("currency mismatch: #{@currency} vs #{other.currency}") unless @currency == other.currency
  end
end

# ---- Demonstration ----------------------------------------------------------
a = Money.of(5.00)
b = Money.of(5.00)
puts a == b                 # true
c = a + Money.of(2.50)
puts c
puts c - Money.of(0.50)
puts (a * 3)
begin
  a + Money.of(1.00, "EUR")
rescue ex
  puts "Rejected: #{ex.message}"
end

# =============================================================================
# EXERCISE 1
#   Add `zero(currency)` and `>`, `<` comparisons.
# SOLUTION 1:
#   def self.zero(currency : String = "USD") : Money; new(0_i64, currency); end
#   def >(other : Money) : Bool; check_same_currency!(other); @amount_cents > other.amount_cents; end
#   def <(other : Money) : Bool; check_same_currency!(other); @amount_cents < other.amount_cents; end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add `percent(pct : Float64) : Money`.
# SOLUTION 2:
#   def percent(pct : Float64) : Money
#     Money.new((@amount_cents  pct / 100.0).round.to_i64, @currency)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain why mutability would break equality-based containers.
# SOLUTION 3:
#   If @amount_cents could change after insertion into a Set/Hash keyed by
#   value, the object's hash and equality would shift, leaving the container
#   in an inconsistent state (lookup by equal-value key would fail). Value
#   objects must be immutable to be safely shared.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
