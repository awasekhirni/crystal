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
#   A receptionist keeps a logbook: every call to the office and every reply
#   goes in the log. The log proxy records requests/responses transparently,
#   without the real service knowing.
#
# SETUP:
#   crystal run 063_proxy_logging.cr
# =============================================================================

# Module `Calculator`.
module Calculator
  # Add an element and return self for chaining.
  abstract def add(a : Int32, b : Int32) : Int32
end

# Concrete class `RealCalculator`.
class RealCalculator
  include Calculator
  # Add an element and return self for chaining.
  def add(a : Int32, b : Int32) : Int32; a + b; end
end

# Logging proxy: same interface, same return, plus side effect.
class LoggingCalculator
  include Calculator
  getter log = [] of String

  def initialize(@real : Calculator); end

  # Add an element and return self for chaining.
  def add(a : Int32, b : Int32) : Int32
    @log << "add(#{a}, #{b})"
    result = @real.add(a, b)
    @log << "=> #{result}"
    result
  end
end

# ---- Demonstration ----------------------------------------------------------
calc = LoggingCalculator.new(RealCalculator.new)
puts calc.add(2, 3)
puts calc.add(10, 20)
puts calc.log

# =============================================================================
# EXERCISE 1
#   Add a "timing" proxy that measures elapsed time.
# SOLUTION 1:
#   class TimingCalculator
#     include Calculator
#     def initialize(@inner : Calculator); end
#     def add(a, b)
#       start = Time.monotonic
#       result = @inner.add(a, b)
#       elapsed = Time.monotonic - start
#       puts "[timing] #{elapsed.total_milliseconds.round(3)}ms"
#       result
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Stack timing outside logging — show sample output.
# SOLUTION 2:
#   stack = TimingCalculator.new(LoggingCalculator.new(RealCalculator.new))
#   stack.add(1, 2)
#   # Logs "[timing] ...ms"; the log array is inside the inner LoggingCalculator.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Difference from Decorator again: which one keeps "the log" inside?
# SOLUTION 3:
#   Both can. The differentiator is intent + usage: a logging proxy is
#   typically ONE wrapper that stands in for a subject to record access;
#   logging decorator is one of many possible add-ons. If you'd never stack
#   two logging layers and the intent is "transparent observability", call
#   it a proxy.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
