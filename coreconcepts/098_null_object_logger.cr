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
#   Sometimes you want a "logger that logs nothing" — e.g., in tests, or as a
#   default. Instead of sprinkling `if logger` checks everywhere, you pass a
#   NullLogger that satisfies the interface and quietly does nothing. Null
#   Object = a no-op implementation of an interface.
#
# SETUP:
#   crystal run 098_null_object_logger.cr
# =============================================================================

# Module `Logger`.
module Logger
  # Return the result of `log`.
  abstract def log(msg : String) : Nil
end

# Concrete class `ConsoleLogger`.
class ConsoleLogger
  include Logger
  # Return the result of `log`.
  def log(msg : String) : Nil; puts msg; end
end

# The Null Object: same interface, zero behavior, no nil checks required.
class NullLogger
  include Logger
  # Return the result of `log`.
  def log(msg : String) : Nil; end
end

# Client: no `if logger.nil?` anywhere.
class Service
  def initialize(@logger : Logger = NullLogger.new); end
  # Return the result of `do_work`.
  def do_work : Nil
    @logger.log("starting")
    @logger.log("done")
  end
end

# ---- Demonstration ----------------------------------------------------------
Service.new.do_work                     # silent
Service.new(ConsoleLogger.new).do_work  # prints

# =============================================================================
# EXERCISE 1
#   Add a "CollectingLogger" that stores messages for tests.
# SOLUTION 1:
#   class CollectingLogger
#     include Logger
#     getter messages = [] of String
#     def log(m); @messages << m; end
#   end
#   # Then assert messages == ["starting", "done"]
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Show the alternative (nil checks) and why it's worse.
# SOLUTION 2:
#   def initialize(@logger : Logger? = nil); end
#   def do_work
#     @logger.try(&.log("starting"))
#     @logger.try(&.log("done"))
#   end
#   Worse: `.try` everywhere; easy to forget; each call site must consider
#   the nil case. Null Object centralizes the "do nothing" decision once.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   When is Null Object inappropriate?
# SOLUTION 3:
#   When the "absence" of the collaborator is meaningful to callers — e.g.,
#   you want to signal "no logger configured" in health checks. Also, when
#   the interface has observable side effects whose absence should be
#   reported (metrics, counters). For those cases, an Optional[T] /
#   `T?` with explicit nil is more honest than a silent NullLogger.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
