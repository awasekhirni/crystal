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
#   A shallow copy is like photocopying a page that contains a link to a
#   website: the link still points to the same site. A deep copy copies the
#   site too. In OOP, shallow copies share referenced objects; deep copies
#   don't.
#
# SETUP:
#   crystal run 038_prototype_deep_vs_shallow.cr
# =============================================================================

# Concrete class `Address`.
class Address
  getter city : String
  def initialize(@city : String); end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << @city; end
end

# Concrete class `Customer`.
class Customer
  getter name : String
  getter address : Address
  getter tags : Array(String)

  def initialize(@name : String, @address : Address, @tags : Array(String)); end

  # Shallow copy: `dup` shares `address` and `tags` references.
  def shallow_copy : Customer
    Customer.new(@name.dup, @address, @tags)
  end

  # Deep copy: creates independent nested objects.
  def deep_copy : Customer
    Customer.new(@name.dup, Address.new(@address.city.dup), @tags.dup)
  end
end

# ---- Demonstration ----------------------------------------------------------
orig = Customer.new("Ann", Address.new("Oslo"), ["vip"])
sh = orig.shallow_copy
dp = orig.deep_copy

# Mutating the original's nested state leaks into the shallow copy:
orig.tags << "gold"
orig.address # Address object is shared; city mutation would affect both
puts "orig tags:    #{orig.tags}"
puts "shallow tags: #{sh.tags} (shared!)"
puts "deep tags:    #{dp.tags} (independent)"

# =============================================================================
# EXERCISE 1
#   Prove that the shared Address between orig and sh is the SAME instance.
# SOLUTION 1:
#   # object_id comparison
#   puts orig.address.same?(sh.address)   # true
#   puts orig.address.same?(dp.address)   # false
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Implement a generic deep-copy helper for arrays of strings.
# SOLUTION 2:
#   def self.deep_array_copy(arr : Array(String)) : Array(String)
#     arr.map(&.dup)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   When is shallow copy acceptable even in a "prototype" context?
# SOLUTION 3:
#   When the shared fields are immutable (frozen Strings, immutable value
#   objects, symbols), sharing is safe and cheaper. Deep copies matter only
#   for mutable substructures the clone might modify independently.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
