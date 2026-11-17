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
#   A guest checkout: there is no logged-in user. Every method that asks "who
#   is the user?" could get nil. Instead of `if user` everywhere, use a
#   GuestUser Null Object with the same methods (e.g., `admin? => false`).
#
# SETUP:
#   crystal run 099_null_object_user.cr
# =============================================================================

# Module `User`.
module User
  # Return the human-readable name of this state/object.
  abstract def name : String
  # Return true if `admin` holds.
  abstract def admin? : Bool
  # Return the result of `cart_id`.
  abstract def cart_id : String
end

# Concrete class `RegisteredUser`.
class RegisteredUser
  include User
  getter name : String, cart_id : String
  def initialize(@name : String, @cart_id : String); end
  # Return true if `admin` holds.
  def admin? : Bool; @name == "root"; end
end

# Null Object: represents "no user" with the same shape.
class GuestUser
  include User
  # Return the human-readable name of this state/object.
  def name : String; "Guest"; end
  # Return true if `admin` holds.
  def admin? : Bool; false; end
  # Return the result of `cart_id`.
  def cart_id : String; "guest-cart"; end
end

# Client code works uniformly.
def greet(user : User) : String
  role = user.admin? ? "(admin)" : "(customer)"
  "Hello #{user.name} #{role}, cart=#{user.cart_id}"
end

# ---- Demonstration ----------------------------------------------------------
puts greet(RegisteredUser.new("Alice", "c-1"))
puts greet(GuestUser.new)
# No nil checks needed at any call site.

# =============================================================================
# EXERCISE 1
#   Add an "AnonymousUser" for a different session type with its own cart.
# SOLUTION 1:
#   class AnonymousUser
#     include User
#     def name; "Anonymous"; end
#     def admin?; false; end
#     def cart_id; "anon-cart"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Show a method that legitimately wants Optional[User] — and how to bridge.
# SOLUTION 2:
#   def register(user : User?) : String
#     case user
#     when nil then "not registered"
#     else          "welcome #{user.name}"
#     end
#   end
#   # For "did the caller send a user?" question, keeping Optional is honest.
#   # Convert at the boundary: `user || GuestUser.new` for the cart flow.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Null Object vs Optional[T]: when to prefer which?
# SOLUTION 3:
#   Null Object when absence is a normal case and the client doesn't care
#   (defaults, safe no-op). Optional[T] when absence is a signal the caller
#   must inspect (login required, find semantics). Mixing both is fine:
#   expose Optional at the boundary, replace with Null Object inside for
#   polymorphic flow.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
