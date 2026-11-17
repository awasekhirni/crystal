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
#   In a school there's exactly one principal. Everyone who asks "who is the
#   principal?" gets the same person. Singleton = exactly one instance,
#   reachable through a single known entry point.
#
# SETUP:
#   crystal run 039_singleton_config.cr
# =============================================================================

# Classic Singleton. `private_class_method new` (via `private` on the class
# constructor) prevents external instantiation.
class AppConfig
  # Class variable (shared across all references).
  @@instance : AppConfig?

  getter env : String
  getter app_name : String

  private def initialize(@env : String, @app_name : String); end

  # The single entry point.
  def self.instance : AppConfig
    @@instance ||= new(default_env, "demo_app")
  end

  # Allow tests to set up config once — but still exactly one instance.
  def self.configure(env : String, app_name : String) : Nil
    @@instance = new(env, app_name)
  end

  private def self.default_env : String
    ENV["APP_ENV"]? || "development"
  end

  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil
    io << "AppConfig(env=#{@env}, name=#{@app_name})"
  end
end

# ---- Demonstration ----------------------------------------------------------
puts AppConfig.instance
puts AppConfig.instance.same?(AppConfig.instance)  # => true

AppConfig.configure("production", "shop")
puts AppConfig.instance

# =============================================================================
# EXERCISE 1
#   Add a `#reset` (test-only) method guarded to development env.
# SOLUTION 1:
#   def self.reset! : Nil
#     raise "reset! only allowed in dev" unless instance.env == "development"
#     @@instance = nil
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add `fetch(key, default)` config values without extra state leaking.
# SOLUTION 2:
#   @values = {} of String => String
#   def [](key : String) : String?; @values[key]?; end
#   def []=(key : String, value : String); @values[key] = value; end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain why "global mutable state" makes Singletons fragile in tests.
# SOLUTION 3:
#   A singleton persists across tests in the same process, so one test's
#   mutation (e.g., AppConfig.configure) leaks into the next. Mitigations:
#   reset hooks (as above), dependency-injection where the same value is
#   passed around, or an "environment struct" whose lifetime is per test.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
