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
#   A vending machine has states: Idle (waiting for money), HasMoney (waiting
#   for selection), Dispensing (dropping product). Each state reacts
#   differently to "insert coin", "select", "refund".
#
# SETUP:
#   crystal run 086_state_vending.cr
# =============================================================================

# --- State interface -------------------------------------------------------
module VendingState
  # Return the result of `insert_coin`.
  abstract def insert_coin(machine : VendingMachine, amount : Int32) : String
  # Return the result of `select`.
  abstract def select(machine : VendingMachine, product : String) : String
  # Return the result of `refund`.
  abstract def refund(machine : VendingMachine) : String
end

# --- Context --------------------------------------------------------------
class VendingMachine
  property state : VendingState
  property balance : Int32 = 0
  getter price : Int32

  def initialize(@price : Int32 = 100); @state = Idle.new; end

  # Return the result of `insert_coin`.
  def insert_coin(amt : Int32) : String; @state.insert_coin(self, amt); end
  # Return the result of `select`.
  def select(product : String) : String; @state.select(self, product); end
  # Return the result of `refund`.
  def refund : String; @state.refund(self); end
end

# --- Concrete states ------------------------------------------------------
class Idle
  include VendingState
  # Return the result of `insert_coin`.
  def insert_coin(m : VendingMachine, amt : Int32) : String
    m.balance = amt
    m.state = HasMoney.new
    "inserted #{amt}"
  end
  # Return the result of `select`.
  def select(m : VendingMachine, p : String) : String; "insert a coin first"; end
  # Return the result of `refund`.
  def refund(m : VendingMachine) : String; "no balance"; end
end

# Concrete class `HasMoney`.
class HasMoney
  include VendingState
  # Return the result of `insert_coin`.
  def insert_coin(m : VendingMachine, amt : Int32) : String
    m.balance += amt
    "inserted #{amt} (balance #{m.balance})"
  end
  # Return the result of `select`.
  def select(m : VendingMachine, p : String) : String
    if m.balance < m.price
      return "insufficient funds (need #{m.price - m.balance} more)"
    end
    change = m.balance - m.price
    m.balance = 0
    m.state = Idle.new
    "dispensed #{p}" + (change > 0 ? ", change #{change}" : "")
  end
  # Return the result of `refund`.
  def refund(m : VendingMachine) : String
    refunded = m.balance
    m.balance = 0
    m.state = Idle.new
    "refunded #{refunded}"
  end
end

# ---- Demonstration ----------------------------------------------------------
vm = VendingMachine.new(100)
puts vm.insert_coin(25)
puts vm.insert_coin(50)
puts vm.select("Cola")     # insufficient
puts vm.insert_coin(50)
puts vm.select("Cola")     # dispensed, change 25
puts vm.select("Cola")     # idle state → "insert a coin first"

# =============================================================================
# EXERCISE 1
#   Add a "Dispensing" state that mimics product falling and then returns to Idle.
# SOLUTION 1:
#   class Dispensing
#     include VendingState
#     def insert_coin(m, a); "wait, dispensing"; end
#     def select(m, p); "wait, dispensing"; end
#     def refund(m); "cannot refund during dispensing"; end
#   end
#   # In HasMoney#select, set m.state = Dispensing.new, capture product, and
#   # arrange a follow-up call to reset to Idle.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add stock per product; reject when stock = 0.
# SOLUTION 2:
#   VendingMachine gets @stock : Hash(String, Int32).
#   HasMoney#select checks stock before dispensing and decrements.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain why state class files are usually short but many.
# SOLUTION 3:
#   Each state class does one job (SRP): react to a fixed set of events.
#   Files are short; collectively they cover all transition rules. The
#   trade-off vs a single `case` is more files but clearer invariants, easier
#   testing, and simpler extension (add a class, don't edit existing ones).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
