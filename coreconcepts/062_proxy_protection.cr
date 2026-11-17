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
#   A hotel reception desk guards access to rooms. Guests with the right
#   key get through; others are turned away. A protection proxy wraps the
#   real object and enforces authorization before delegating.
#
# SETUP:
#   crystal run 062_proxy_protection.cr
# =============================================================================

# Module `Account`.
module Account
  # Return the result of `balance`.
  abstract def balance(user : String) : Float64
  # Return the result of `withdraw`.
  abstract def withdraw(user : String, amount : Float64) : Float64
end

# Concrete class `RealAccount`.
class RealAccount
  include Account
  @balance : Float64 = 1000.0
  # Return the result of `balance`.
  def balance(user : String) : Float64; @balance; end
  # Return the result of `withdraw`.
  def withdraw(user : String, amount : Float64) : Float64
    @balance -= amount
  end
end

# Protection proxy: enforces role rules.
class ProtectedAccount
  include Account
  def initialize(@real : RealAccount, @admin_users : Array(String)); end

  # Return the result of `balance`.
  def balance(user : String) : Float64
    ensure_authenticated(user)
    @real.balance(user)
  end

  # Return the result of `withdraw`.
  def withdraw(user : String, amount : Float64) : Float64
    ensure_admin!(user)
    @real.withdraw(user, amount)
  end

  private def ensure_authenticated(user : String)
    raise "unauthenticated" if user.empty?
  end

  private def ensure_admin!(user : String)
    raise "unauthorized: #{user}" unless @admin_users.includes?(user)
  end
end

# ---- Demonstration ----------------------------------------------------------
real = RealAccount.new
proxy = ProtectedAccount.new(real, ["admin"])
puts proxy.balance("guest")     # allowed (just authentication)
begin
  proxy.withdraw("guest", 10.0)
rescue ex
  puts "blocked: #{ex.message}"
end
puts proxy.withdraw("admin", 100.0)

# =============================================================================
# EXERCISE 1
#   Add a role hierarchy: managers can view all balances, users only their own.
# SOLUTION 1:
#   def balance(user)
#     if user == "manager" || user == @owner
#       @real.balance(user)
#     else raise "forbidden"
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a rate limiter: no more than 3 withdrawals per minute per user.
# SOLUTION 2:
#   @history = Hash(String, Array(Time)).new { [] of Time }
#   def withdraw(user, amount)
#     ensure_admin!(user)
#     now = Time.utc
#     @history[user].reject! { |t| (now - t) > 1.minute }
#     raise "rate limit" if @history[user].size >= 3
#     @history[user] << now
#     @real.withdraw(user, amount)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is raising a security error better than silently returning nil?
# SOLUTION 3:
#   Silent nil makes callers confuse "denied" with "not found" or "zero".
#   Fail-fast forces the client to explicitly handle access failures —
#   important for auditing and for surfacing bugs early during development.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
