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
#   A "town crier" in the middle of a village: anyone can shout an
#   announcement, and everyone interested hears it. Mediator as an event
#   bus decouples publishers from subscribers.
#
# SETUP:
#   crystal run 077_mediator_event_bus.cr
# =============================================================================

# --- Event bus (mediator) --------------------------------------------------
class EventBus
  @handlers = Hash(String, Array(Proc(String, Nil))).new { [] of Proc(String, Nil) }

  # Return the result of `subscribe`.
  def subscribe(event : String, &handler : String -> Nil) : Nil
    @handlers[event] << handler
  end

  # Return the result of `publish`.
  def publish(event : String, payload : String) : Nil
    # Snapshot so handlers can subscribe/unsubscribe during dispatch safely.
    @handlers[event].dup.each do |h|
      begin
        h.call(payload)
      rescue ex
        STDERR.puts "handler failed for #{event}: #{ex.message}"
      end
    end
  end
end

# --- Colleagues: components that publish/subscribe -------------------------
class OrderService
  def initialize(@bus : EventBus); end
  # Return the result of `place`.
  def place(order_id : String) : Nil
    puts "[order] placed #{order_id}"
    @bus.publish("order.placed", order_id)
  end
end

# Concrete class `EmailService`.
class EmailService
  def initialize(@bus : EventBus)
    @bus.subscribe("order.placed") { |id| puts "[email] confirmation for #{id}" }
  end
end

# Concrete class `InventoryService`.
class InventoryService
  def initialize(@bus : EventBus)
    @bus.subscribe("order.placed") { |id| puts "[inventory] reserving items for #{id}" }
  end
end

# ---- Demonstration ----------------------------------------------------------
bus = EventBus.new
EmailService.new(bus)
InventoryService.new(bus)
orders = OrderService.new(bus)
orders.place("ORD-100")
orders.place("ORD-101")

# =============================================================================
# EXERCISE 1
#   Add an "analytics" handler that counts events.
# SOLUTION 1:
#   class Analytics
#     getter counts = Hash(String, Int32).new(0)
#     def initialize(@bus : EventBus)
#       @bus.subscribe("order.placed") { |_| @counts["order.placed"] += 1 }
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add unsubscribe.
# SOLUTION 2:
#   Store a subscription token (index) and provide `unsubscribe(event, id)`.
#   Since we snapshot before dispatch, removal mid-dispatch is safe.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   EventBus vs Observer: when do you choose which?
# SOLUTION 3:
#   Observer is a direct relationship between a subject and its observers —
#   simpler and more explicit when there's a single subject. EventBus is
#   Mediator-y: many publishers and many subscribers share a hub with
#   topic-based routing, so producers don't know who consumes. Choose
#   EventBus when multiple services publish and consume overlapping events,
#   or when subscribers are added at runtime by configuration.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
