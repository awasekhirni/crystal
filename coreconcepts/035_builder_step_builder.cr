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
#   Have you ever filled a form where you MUST fill the name before the
#   address? A step-builder makes the compiler enforce that order — you
#   literally can't skip a required step.
#
# SETUP:
#   crystal run 035_builder_step_builder.cr
# =============================================================================

# Concrete class `Connection`.
class Connection
  getter host : String, port : Int32, user : String, password : String

  def initialize(@host : String, @port : Int32, @user : String, @password : String)
  end

  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil
    io << "Connection(#{@user}@#{@host}:#{@port})"
  end
end

# Each "step" is a small class that exposes only the next method(s). This
# forces callers to complete required steps in a compile-time safe order.
class HostStep
  # Return the result of `host`.
  def host(h : String) : PortStep; PortStep.new(h); end
end

# Concrete class `PortStep`.
class PortStep
  def initialize(@host : String); end
  # Return the result of `port`.
  def port(p : Int32) : UserStep; UserStep.new(@host, p); end
end

# Concrete class `UserStep`.
class UserStep
  def initialize(@host : String, @port : Int32); end
  # Return the result of `user`.
  def user(u : String) : PasswordStep; PasswordStep.new(@host, @port, u); end
end

# Concrete class `PasswordStep`.
class PasswordStep
  def initialize(@host : String, @port : Int32, @user : String); end
  # Return the result of `password`.
  def password(pw : String) : Connection
    Connection.new(@host, @port, @user, pw)
  end
end

# Entry point: DSL-like chain, enforced by types.
module ConnectionBuilder
  # Return the result of `self`.
  def self.start : HostStep
    HostStep.new
  end
end

# ---- Demonstration ----------------------------------------------------------
conn = ConnectionBuilder
  .start
  .host("db.example.com")
  .port(5432)
  .user("admin")
  .password("s3cret")
puts conn

# =============================================================================
# EXERCISE 1
#   Add an OPTIONAL step `ssl(bool)` between user and password. Because it's
#   optional, the caller must be able to skip it — explain the design tension.
# SOLUTION 1:
#   Introduce PasswordOrSslStep with both `password` and `ssl` returning
#   PasswordStep. Optional steps are modeled as small "fork" nodes. This
#   shows step builders can model optionality — at the cost of more classes.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Why is this more valuable for APIs than for internal DSLs?
# SOLUTION 2:
#   Public API users may not read docs; the type system prevents misuse.
#   Internally, developers can learn a conventional chain quickly, so the
#   ceremony may not pay off. Compile-time safety shines at API boundaries.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Which GoF pattern's spirit does this echo, and why is it not a violation?
# SOLUTION 3:
#   It echoes the Builder pattern's intent (construct step-by-step). Using
#   small typed step-classes is an implementation detail; the intent and
#   responsibilities (accumulate state, produce product once) remain intact.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
