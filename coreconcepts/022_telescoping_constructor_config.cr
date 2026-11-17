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
#   Imagine ordering a sandwich and the cashier says "name, bread, cheese,
#   tomato, lettuce, mayo, mustard, pickles, olives, size, wrapper?" — ten
#   parameters, most optional. That's the "telescoping constructor" smell.
#   This example shows the smell; the Builder pattern (later) fixes it.
#
# SETUP:
#   crystal run 022_telescoping_constructor_config.cr
# =============================================================================

# --- The smell: overloads that keep growing --------------------------------
class ServerConfig
  getter host : String, port : Int32, tls : Bool, timeout : Int32, workers : Int32, name : String

  # The infamous parameter list. Hard to read at call sites, easy to swap
  # two arguments of the same type, painful to add a new option.
  def initialize(@host : String = "localhost",
                 @port : Int32 = 8080,
                 @tls : Bool = false,
                 @timeout : Int32 = 30,
                 @workers : Int32 = 4,
                 @name : String = "default")
  end

  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil
    io << "Server(host=#{@host}, port=#{@port}, tls=#{@tls}, " \
          "timeout=#{@timeout}s, workers=#{@workers}, name=#{@name})"
  end
end

# ---- Demonstration: hard to read, easy to misuse ---------------------------
# Which is timeout and which is workers? Both Int32 — silent bug!
puts ServerConfig.new("db.example.com", 5432, true, 60, 8, "db")
puts ServerConfig.new("api.example.com", 443, true)   # remaining defaults

# =============================================================================
# EXERCISE 1
#   Show that swapping timeout and workers compiles but is wrong.
# SOLUTION 1:
#   cfg = ServerConfig.new("x", 80, false, 4, 30)
#   # If intended: timeout=30, workers=4 — but we passed timeout=4, workers=30.
#   # The compiler cannot help: two Int32s look identical.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Propose two remedies without changing ServerConfig's fields.
# SOLUTION 2:
#   (a) Named arguments: ServerConfig.new(host: "x", timeout: 30, workers: 4).
#       Crystal makes named args mandatory if you use them — safe for large
#       lists but still verbose at every call site.
#   (b) Builder pattern (see 031+): ServerConfig::Builder.new
#         .host("x").port(80).timeout(30).workers(4).build
#       Reads naturally, enforces required fields, validates once.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Which SOLID principle is being violated at construction time?
# SOLUTION 3:
#   SRP (the constructor does too much and hides intent) and OCP (adding a
#   field often means editing every overload). The Builder moves construction
#   into a dedicated object, restoring both.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
