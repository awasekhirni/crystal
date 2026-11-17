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
#   A fraud-detection system has rules: "amount > 1000 AND country != US".
#   Each rule is an object; combine with AND/OR/NOT to form composite rules.
#   Interpreter for rules (a boolean mini-language).
#
# SETUP:
#   crystal run 097_interpreter_rules.cr
# =============================================================================

# --- Rule interface --------------------------------------------------------
module Rule
  # Return true if `matches` holds.
  abstract def matches?(txn : Hash(String, String)) : Bool
  # Append this object's String representation to `io`.
  abstract def to_s(io : IO) : Nil
end

# --- Terminals ------------------------------------------------------------
class Equals
  include Rule
  def initialize(@field : String, @value : String); end
  # Return true if `matches` holds.
  def matches?(txn) : Bool; txn[@field]? == @value; end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "#{@field}=#{@value}"; end
end

# Concrete class `GreaterThan`.
class GreaterThan
  include Rule
  def initialize(@field : String, @value : Float64); end
  # Return true if `matches` holds.
  def matches?(txn) : Bool
    (txn[@field]?.try(&.to_f) || 0.0) > @value
  end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "#{@field}>#{@value}"; end
end

# Concrete class `NotEquals`.
class NotEquals
  include Rule
  def initialize(@field : String, @value : String); end
  # Return true if `matches` holds.
  def matches?(txn) : Bool; txn[@field]? != @value; end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "#{@field}!=#{@value}"; end
end

# --- Combinators (non-terminals) -----------------------------------------
class And
  include Rule
  def initialize(@left : Rule, @right : Rule); end
  # Return true if `matches` holds.
  def matches?(txn) : Bool; @left.matches?(txn) && @right.matches?(txn); end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "(" << @left << " AND " << @right << ")"; end
end

# Concrete class `Or`.
class Or
  include Rule
  def initialize(@left : Rule, @right : Rule); end
  # Return true if `matches` holds.
  def matches?(txn) : Bool; @left.matches?(txn) || @right.matches?(txn); end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "(" << @left << " OR " << @right << ")"; end
end

# Concrete class `Not`.
class Not
  include Rule
  def initialize(@inner : Rule); end
  # Return true if `matches` holds.
  def matches?(txn) : Bool; !@inner.matches?(txn); end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "NOT(" << @inner << ")"; end
end

# --- Build a rule: amount > 1000 AND country != US --------------------
rule = And.new(
  GreaterThan.new("amount", 1000.0),
  NotEquals.new("country", "US")
)

# ---- Demonstration ----------------------------------------------------------
transactions = [
  {"amount" => "500",  "country" => "DE"},
  {"amount" => "1500", "country" => "DE"},
  {"amount" => "2000", "country" => "US"},
  {"amount" => "1200", "country" => "BR"},
]
transactions.each do |txn|
  flagged = rule.matches?(txn)
  puts "#{txn}: flagged=#{flagged}"
end
puts "Rule: #{rule}"

# =============================================================================
# EXERCISE 1
#   Add "Between(field, min, max)" terminal.
# SOLUTION 1:
#   class Between
#     include Rule
#     def initialize(@field, @min : Float64, @max : Float64); end
#     def matches?(txn)
#       v = (txn[@field]?.try(&.to_f) || 0.0)
#       v >= @min && v <= @max
#     end
#     def to_s(io); io << @field << " in [" << @min << "," << @max << "]"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "TopTransactions" composite: matches if any txn in a batch matches.
# SOLUTION 2:
#   class AnyMatch
#     include Rule
#     def initialize(@inner : Rule); end
#     def matches?(txn); @inner.matches?(txn); end
#     def to_s(io); io << "ANY(" << @inner << ")"; end
#   end
#   # (In practice you'd pass Array(txn); adjust signature accordingly.)
# =============================================================================

# =============================================================================
# EXERCISE 3
#   How is this pattern related to Composite? To Visitor?
# SOLUTION 3:
#   The rule tree is Composite: terminals are leaves, combinators are
#   containers, both share Rule. Visitor would let you add operations like
#   "explain which clause failed" without editing the rule classes —
#   Interpreter defines behavior (eval) inside the tree; Visitor pulls it out.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
