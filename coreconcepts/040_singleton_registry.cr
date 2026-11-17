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
#   A lost-and-found desk in a mall: one per mall. Everyone who loses or
#   finds an item goes to the SAME desk. A service registry is a "singleton
#   dictionary" that applications use to look up shared services.
#
# SETUP:
#   crystal run 040_singleton_registry.cr
# =============================================================================

# A marker module every registered service must include.  Crystal forbids
# using the top-level `Object` type as an instance-variable type because it
# would defeat the compiler's union inference; a narrow marker module keeps
# the registry open for any service while still being statically typed.
module Service
end

# A registry is often the better alternative to hardcoded singletons:
# one well-known registry object, many services registered inside it.
# Tests can spin up a registry, swap it, and isolate state.
class ServiceRegistry
  @services = {} of String => Service
  @lock = Mutex.new

  # Register `service` under `name`.  Returns Nil.
  def register(name : String, service : Service) : Nil
    @lock.synchronize { @services[name] = service }
  end

  # Look up the service registered under `name` (raises if missing).
  def resolve(name : String) : Service
    @lock.synchronize { (@services[name]? || raise "missing: #{name}") }
  end

  # Typed lookup convenience: pass the expected class.
  def resolve_as(klass : T.class, name : String) : T forall T
    service = resolve(name)
    raise "wrong type for #{name}: got #{service.class}" unless service.is_a?(T)
    service
  end
end

# The "global" registry is created lazily and exposed via a class method,
# which is the singleton facade. Internally it's just another object.
class Global
  @@registry : ServiceRegistry?
  # Return the result of `self`.
  def self.registry : ServiceRegistry
    @@registry ||= ServiceRegistry.new
  end
end

# --- Demo services -----------------------------------------------------------
class Clock
  include Service

  # Return the current UTC time as a String.
  def now : String; Time.utc.to_s; end
end

# Concrete class `Greeter`.
class Greeter
  include Service
  def initialize(@clock : Clock); end
  # Return a friendly greeting String.
  def greet : String; "hello at #{@clock.now}"; end
end

# ---- Demonstration ----------------------------------------------------------
reg = Global.registry
reg.register("clock", Clock.new)
reg.register("greeter", Greeter.new(reg.resolve_as(Clock, "clock")))

puts reg.resolve_as(Greeter, "greeter").greet

# =============================================================================
# EXERCISE 1
#   Add a `swap` method that replaces a service atomically.
# SOLUTION 1:
#   def swap(name : String, service : Service) : Service?
#     @lock.synchronize do
#       old = @services[name]?
#       @services[name] = service
#       old
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Provide a test-scoped registry without touching Global.
# SOLUTION 2:
#   # In tests, don't call Global.registry; instead create a fresh one:
#   test_reg = ServiceRegistry.new
#   test_reg.register("clock", FakeClock.new)
#   # Pass test_reg explicitly to services under test — DIP-friendly.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is "singleton registry + DI" a common compromise vs. classic Singleton?
# SOLUTION 3:
#   A classic Singleton hard-couples every caller to the global type. A
#   singleton registry is just one shared object; services still receive
#   their collaborators via constructor injection. Tests can inject a
#   fresh registry without touching global state. You keep one entry point
#   for wiring but regain test isolation.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
