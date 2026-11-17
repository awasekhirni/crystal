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
#   You submit an expense. Small amounts are approved by your manager;
#   bigger ones by the director; huge ones by the CFO. Each approver can
#   either handle it or pass it up the chain. Chain of Responsibility = link
#   handlers so each decides whether to handle or forward.
#
# SETUP:
#   crystal run 066_chain_of_responsibility_expense.cr
# =============================================================================

# --- Handler abstraction ----------------------------------------------------
abstract class Approver
  def initialize(@name : String); end

  # Each approver holds a reference to its successor (nil if last).
  @next : Approver?

  # Fluent chain builder: sets successor and returns it, so we can chain calls.
  def chain(next_approver : Approver?) : Approver?
    @next = next_approver
    next_approver
  end

  # Template method: subclasses decide `can_approve?` and `approve`.
  def process(amount : Float64) : String
    if can_approve?(amount)
      approve(amount)
    elsif @next
      @next.not_nil!.process(amount)
    else
      "REJECTED: no one can approve $#{amount}"
    end
  end

  # Return true if `can_approve` holds.
  abstract def can_approve?(amount : Float64) : Bool
  # Return the result of `approve`.
  abstract def approve(amount : Float64) : String
end

# Concrete class `Manager` -- extends Approver.
class Manager < Approver
  # Return true if `can_approve` holds.
  def can_approve?(amount : Float64) : Bool; amount <= 100.0; end
  # Return the result of `approve`.
  def approve(amount : Float64) : String; "#{@name} (Manager) approved $#{amount}"; end
end

# Concrete class `Director` -- extends Approver.
class Director < Approver
  # Return true if `can_approve` holds.
  def can_approve?(amount : Float64) : Bool; amount <= 1000.0; end
  # Return the result of `approve`.
  def approve(amount : Float64) : String; "#{@name} (Director) approved $#{amount}"; end
end

# Concrete class `CFO` -- extends Approver.
class CFO < Approver
  # Return true if `can_approve` holds.
  def can_approve?(amount : Float64) : Bool; amount <= 10_000.0; end
  # Return the result of `approve`.
  def approve(amount : Float64) : String; "#{@name} (CFO) approved $#{amount}"; end
end

# --- Build the chain --------------------------------------------------------
manager  = Manager.new("Alice")
director = Director.new("Bob")
cfo      = CFO.new("Carol")

manager.chain(director).not_nil!.chain(cfo)

# ---- Demonstration ----------------------------------------------------------
[50.0, 750.0, 5000.0, 50_000.0].each do |amt|
  puts manager.process(amt)
end

# =============================================================================
# EXERCISE 1
#   Add a CEO who approves anything below 100k, reject above.
# SOLUTION 1:
#   class CEO < Approver
#     def can_approve?(amount); amount <= 100_000.0; end
#     def approve(amount); "#{@name} (CEO) approved $#{amount}"; end
#   end
#   cfo.chain(CEO.new("Dave"))
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add an "audit" handler at the end that logs REJECTED but doesn't reject.
# SOLUTION 2:
#   # Add an always-approve "finalizer" after CFO to record attempted amounts.
#   # Alternatively, wrap process() with an audit layer (Decorator) that
#   # logs without affecting the decision.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   How is CoR related to a linked list and to a middleware pipeline?
# SOLUTION 3:
#   It's literally a linked list of handlers with a common interface. Each
#   node decides to handle or forward. Middleware pipelines are CoR where
#   every handler usually forwards after its own pre/post logic — used by
#   frameworks (e.g., HTTP middleware).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
