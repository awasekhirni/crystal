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
#   If a viewer unsubscribes but the TV keeps playing, that's fine — but if
#   the TV remembers every viewer forever even after they left the room,
#   memory fills up. Long-lived subjects should not prevent observers from
#   being garbage-collected when nobody else uses them.
#
# SETUP:
#   crystal run 083_observer_weak_refs.cr
# =============================================================================

# --- Simplest safe approach: explicit unsubscribe + weak checks ----------
# Crystal's GC does not offer fine-grained weak references in the stdlib for
# regular objects in a portable way, so common practice is:
#  1) Observers implement `#alive?` to self-report liveness.
#  2) Subject prunes dead observers on notify.
# This captures the design idea without GC-specific APIs.
module Observer
  # Return the result of `update`.
  abstract def update(msg : String) : Nil
  # Return true if `alive` holds.
  abstract def alive? : Bool
end

# Concrete class `Subject`.
class Subject
  @observers = [] of Observer
  # Return the result of `subscribe`.
  def subscribe(o : Observer) : Nil; @observers << o; end
  # Return the result of `notify_all`.
  def notify_all(msg : String) : Nil
    # Prune observers that report themselves dead.
    @observers.reject! { |o| !o.alive? }
    @observers.each(&.update(msg))
  end
  # Return the result of `observer_count`.
  def observer_count : Int32; @observers.size; end
end

# --- Observer with a self-managed lifetime flag ---------------------------
class ManagedObserver
  include Observer
  def initialize(@name : String); @alive = true; end
  # Return the result of `kill`.
  def kill : Nil; @alive = false; end
  # Return true if `alive` holds.
  def alive? : Bool; @alive; end
  # Return the result of `update`.
  def update(msg : String) : Nil; puts "#{@name} <- #{msg}"; end
end

# ---- Demonstration ----------------------------------------------------------
subject = Subject.new
a = ManagedObserver.new("A")
b = ManagedObserver.new("B")
subject.subscribe(a)
subject.subscribe(b)
subject.notify_all("hello1")
b.kill
puts "count before notify: #{subject.observer_count}"   # 2
subject.notify_all("hello2")                            # only A
puts "count after notify:  #{subject.observer_count}"   # 1

# =============================================================================
# EXERCISE 1
#   Add refcount-style lifetime: observers auto-kill when their refcount hits 0.
# SOLUTION 1:
#   ManagedObserver holds @refs = 0; def addref; @refs += 1; end;
#   def release; @refs -= 1; kill if @refs == 0; end
#   Subjects (or clients) call addref/release around their lifetime.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Compare with a WeakRef-based design (in languages that support it).
# SOLUTION 2:
#   A weak ref lets the subject hold a reference without preventing GC.
#   When the observer is collected, the subject's next notify prunes it.
#   This is the "canonical" solution; ours is a manual approximation.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   When is explicit unsubscribe simpler than weak refs?
# SOLUTION 3:
#   When observers have clear lifetimes tied to scope (e.g., a component's
#   initialize/subscribe and teardown/unsubscribe, or use a scope object
#   that unsubscribes on destruction). Explicit is simpler, deterministic,
#   and doesn't rely on GC timing. Weak refs shine for long-lived subjects
#   with many short-lived observers whose lifetimes you don't control.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
