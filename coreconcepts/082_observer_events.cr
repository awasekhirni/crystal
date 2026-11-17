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
#   A "subscribe" button on YouTube: when a creator uploads, every subscriber
#   gets an email. Event-based Observer lets one object broadcast many
#   different event types to interested observers.
#
# SETUP:
#   crystal run 082_observer_events.cr
# =============================================================================

# --- Events as a small enum ------------------------------------------------
enum Event
  Created
  Updated
  Deleted
end

# --- Observer with an event-specific hook ---------------------------------
module Listener
  # Return the result of `on`.
  abstract def on(event : Event, data : String) : Nil
end

# --- Subject with multiple event channels ---------------------------------
class Publisher
  @listeners = Hash(Event, Array(Listener)).new { [] of Listener }

  # Return the result of `subscribe`.
  def subscribe(event : Event, listener : Listener) : Nil
    @listeners[event] << listener
  end

  # Return the result of `unsubscribe`.
  def unsubscribe(event : Event, listener : Listener) : Nil
    @listeners[event].delete(listener)
  end

  # Return the result of `emit`.
  def emit(event : Event, data : String) : Nil
    @listeners[event].dup.each do |l|
      begin
        l.on(event, data)
      rescue ex
        STDERR.puts "listener failed on #{event}: #{ex.message}"
      end
    end
  end
end

# --- Concrete listeners ---------------------------------------------------
class AuditLog
  include Listener
  # Return the result of `on`.
  def on(event : Event, data : String) : Nil
    puts "[audit] #{event}: #{data}"
  end
end

# Concrete class `EmailAlert`.
class EmailAlert
  include Listener
  # Return the result of `on`.
  def on(event : Event, data : String) : Nil
    return unless event == Event::Deleted
    puts "[email] removed: #{data}"
  end
end

# ---- Demonstration ----------------------------------------------------------
publisher = Publisher.new
audit = AuditLog.new
email = EmailAlert.new
publisher.subscribe(Event::Created, audit)
publisher.subscribe(Event::Updated, audit)
publisher.subscribe(Event::Deleted, audit)
publisher.subscribe(Event::Deleted, email)

publisher.emit(Event::Created, "user#1")
publisher.emit(Event::Updated, "user#1")
publisher.emit(Event::Deleted, "user#1")

# =============================================================================
# EXERCISE 1
#   Add an "uncaught failure should not drop later listeners" guarantee.
# SOLUTION 1:
#   Already handled: each listener runs in begin/rescue with STDERR.puts.
#   Document this as a robustness contract of Publisher.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "once" subscription that auto-removes after first call.
# SOLUTION 2:
#   Wrap the listener in a OnceListener that holds @fired = false and
#   removes itself via publisher.unsubscribe on first call.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Discuss ordering: do listeners run in subscription order?
# SOLUTION 3:
#   Yes, because we iterate the array in insertion order. If order matters
#   for correctness (e.g., audit before email), state it explicitly, or use
#   a priority field and sort. Otherwise treat listeners as independent.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
