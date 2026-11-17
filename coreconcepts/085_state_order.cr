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
#   An order goes through: Created → Paid → Shipped → Delivered. Trying to
#   ship a non-paid order should be rejected. Each state enforces valid
#   transitions. State pattern = each state decides what's allowed next.
#
# SETUP:
#   crystal run 085_state_order.cr
# =============================================================================

# --- State interface -------------------------------------------------------
module OrderState
  # Return the human-readable name of this state/object.
  abstract def name : String
  # Return the result of `pay`.
  abstract def pay(order : Order) : Nil
  # Return the result of `ship`.
  abstract def ship(order : Order) : Nil
  # Return the result of `deliver`.
  abstract def deliver(order : Order) : Nil
  # Return the result of `cancel`.
  abstract def cancel(order : Order) : Nil
end

# --- Concrete states ------------------------------------------------------
class Created
  include OrderState
  # Return the human-readable name of this state/object.
  def name : String; "CREATED"; end
  # Return the result of `pay`.
  def pay(o : Order) : Nil; o.state = Paid.new; end
  # Return the result of `ship`.
  def ship(o : Order) : Nil; raise "cannot ship un-paid order"; end
  # Return the result of `deliver`.
  def deliver(o : Order) : Nil; raise "cannot deliver un-shipped order"; end
  # Return the result of `cancel`.
  def cancel(o : Order) : Nil; o.state = Cancelled.new; end
end

# Concrete class `Paid`.
class Paid
  include OrderState
  # Return the human-readable name of this state/object.
  def name : String; "PAID"; end
  # Return the result of `pay`.
  def pay(o : Order) : Nil; raise "already paid"; end
  # Return the result of `ship`.
  def ship(o : Order) : Nil; o.state = Shipped.new; end
  # Return the result of `deliver`.
  def deliver(o : Order) : Nil; raise "not shipped yet"; end
  # Return the result of `cancel`.
  def cancel(o : Order) : Nil; o.state = Cancelled.new; end
end

# Concrete class `Shipped`.
class Shipped
  include OrderState
  # Return the human-readable name of this state/object.
  def name : String; "SHIPPED"; end
  # Return the result of `pay`.
  def pay(o : Order) : Nil; raise "already paid"; end
  # Return the result of `ship`.
  def ship(o : Order) : Nil; raise "already shipped"; end
  # Return the result of `deliver`.
  def deliver(o : Order) : Nil; o.state = Delivered.new; end
  # Return the result of `cancel`.
  def cancel(o : Order) : Nil; raise "cannot cancel after shipping"; end
end

# Concrete class `Delivered`.
class Delivered
  include OrderState
  # Return the human-readable name of this state/object.
  def name : String; "DELIVERED"; end
  # Return the result of `pay`.
  def pay(o : Order) : Nil; raise "already delivered"; end
  # Return the result of `ship`.
  def ship(o : Order) : Nil; raise "already delivered"; end
  # Return the result of `deliver`.
  def deliver(o : Order) : Nil; raise "already delivered"; end
  # Return the result of `cancel`.
  def cancel(o : Order) : Nil; raise "cannot cancel delivered"; end
end

# Concrete class `Cancelled`.
class Cancelled
  include OrderState
  # Return the human-readable name of this state/object.
  def name : String; "CANCELLED"; end
  # Return the result of `pay`.
  def pay(o : Order) : Nil; raise "cancelled"; end
  # Return the result of `ship`.
  def ship(o : Order) : Nil; raise "cancelled"; end
  # Return the result of `deliver`.
  def deliver(o : Order) : Nil; raise "cancelled"; end
  # Return the result of `cancel`.
  def cancel(o : Order) : Nil; raise "already cancelled"; end
end

# --- Context --------------------------------------------------------------
class Order
  property state : OrderState
  getter id : String
  def initialize(@id : String); @state = Created.new; end

  # Return the result of `pay`.
  def pay : Nil; @state.pay(self); end
  # Return the result of `ship`.
  def ship : Nil; @state.ship(self); end
  # Return the result of `deliver`.
  def deliver : Nil; @state.deliver(self); end
  # Return the result of `cancel`.
  def cancel : Nil; @state.cancel(self); end
  # Return the result of `status`.
  def status : String; @state.name; end
end

# ---- Demonstration ----------------------------------------------------------
order = Order.new("ORD-1")
puts order.status
order.pay;     puts order.status
order.ship;    puts order.status
order.deliver; puts order.status

begin
  order.cancel
rescue ex
  puts "rejected: #{ex.message}"
end

# =============================================================================
# EXERCISE 1
#   Add a "Refunded" state reachable from Delivered.
# SOLUTION 1:
#   class Refunded; include OrderState
#     # name "REFUNDED"; every action raises "final state".
#   end
#   Delivered#refund sets o.state = Refunded.new.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add an audit hook: Order records each transition.
# SOLUTION 2:
#   Order has `getter history = [] of String`.
#   Each state class calls `o.record("PAID")` before/after setting state.
#   Alternatively, wrap state transitions in a helper.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is "raise on invalid transition" better than returning false?
# SOLUTION 3:
#   Silent-false lets callers proceed in a wrong state ("ship" returned false
#   but code continues). Raise forces callers to explicitly handle the
#   failure — important for invariants (money, physical goods). For APIs you
#   may return a Result type instead, but never silently ignore.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
