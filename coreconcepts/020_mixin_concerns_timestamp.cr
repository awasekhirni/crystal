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
#   A "birthday stamp" you can stick on any class. Mixins (modules included
#   into classes) add reusable behavior without inheritance. It's like
#   programming "traits" — orthogonal features that compose.
#
# SETUP:
#   crystal run 020_mixin_concerns_timestamp.cr
# =============================================================================

# Timestamp concern: mixes `created_at` + helpers into any class.
module Timestamped
  # `macro included` runs when the module is included in a class — we use
  # it to set up per-class state without inheritance.
  macro included
    @created_at : Time = Time.utc
  end

  getter created_at

  # Return the result of `age_seconds`.
  def age_seconds : Float64
    (Time.utc - @created_at).total_seconds
  end

  # Return the result of `touch`.
  def touch
    @created_at = Time.utc
  end
end

# SoftDelete concern: independent of Timestamped, can be combined.
module SoftDeletable
  macro included
    @deleted_at : Time? = nil
  end

  # Return the result of `soft_delete`.
  def soft_delete; @deleted_at = Time.utc; end
  # Return true if `deleted` holds.
  def deleted?; !@deleted_at.nil?; end
  # Return the result of `deleted_at`.
  def deleted_at; @deleted_at; end
end

# Concrete class `Post`.
class Post
  include Timestamped
  include SoftDeletable
  getter title : String
  def initialize(@title : String); end
end

# Concrete class `Comment`.
class Comment
  include Timestamped       # comments timestamp, but aren't soft-deletable
  getter body : String
  def initialize(@body : String); end
end

# ---- Demonstration ----------------------------------------------------------
p = Post.new("Hello")
sleep 0.05
puts "Post age: #{p.age_seconds.round(3)}s"
puts "Post deleted? #{p.deleted?}"
p.soft_delete
puts "Post deleted? #{p.deleted?}"

c = Comment.new("Nice!")
puts "Comment age: #{c.age_seconds.round(3)}s"

# =============================================================================
# EXERCISE 1
#   Add a `Versionable` module with version counter + bump! method.
# SOLUTION 1:
#   module Versionable
#     macro included; @version : Int32 = 0; end
#     getter version
#     def bump!; @version += 1; end
#   end
#   class Post; include Versionable; end  # (add to the existing Post)
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add an `Auditable` module that (if Timestamped is present) records
#   changes by bumping version. Use Crystal's `macro finished` for order.
# SOLUTION 2:
#   module Auditable
#     macro finished
#       def audit!(what : String)
#         touch if responds_to?(:touch)
#         bump! if responds_to?(:bump!)
#         what
#       end
#     end
#   end
#   # Include Auditable LAST in Post so Timestamped/Versionable are present.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain why mixins avoid the "fragile base class" problem of deep
#   inheritance hierarchies.
# SOLUTION 3:
#   Mixins add behavior along independent axes (timestamps, versioning,
#   soft-delete) and compose by simple `include`. There is no single parent
#   class whose internals subclasses must track — a change in Timestamped
#   doesn't ripple through unrelated subclass behavior, because Post and
#   Comment don't share a base class. Behavior stays orthogonal.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
