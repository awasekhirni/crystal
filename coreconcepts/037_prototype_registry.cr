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
#   A "shape library" in a drawing app: the user drags a "saved" star onto
#   the canvas, and a copy appears. The saved star is a prototype — the app
#   keeps a catalogue and copies entries on demand.
#
# SETUP:
#   crystal run 037_prototype_registry.cr
# =============================================================================

# Abstract class `Shape`.
abstract class Shape
  # Return a deep-cloned Shape of the same concrete type.
  abstract def clone_shape : Shape
  # Return a short String describing the drawn shape/node.
  abstract def draw : String
end

# Concrete class `Star` -- extends Shape.
class Star < Shape
  # `property` (not `getter) so callers can tweak a cloned star's size or
  # color before drawing it back to the canvas.
  property size : Int32, color : String
  def initialize(@size : Int32 = 5, @color : String = "gold"); end
  # Return a deep-cloned Shape of the same concrete type.
  def clone_shape : Shape; Star.new(@size, @color.dup); end
  # Return a short String describing the drawn shape/node.
  def draw : String; "Star(#{@size}, #{@color})"; end
end

# Concrete class `Circle` -- extends Shape.
class Circle < Shape
  getter radius : Int32
  def initialize(@radius : Int32 = 10); end
  # Return a deep-cloned Shape of the same concrete type.
  def clone_shape : Shape; Circle.new(@radius); end
  # Return a short String describing the drawn shape/node.
  def draw : String; "Circle(#{@radius})"; end
end

# Prototype registry: stores prototypes and hands out clones. Clients never
# name concrete classes — they request a name.
class ShapeLibrary
  @prototypes = {} of String => Shape

  # Add an element and return self for chaining.
  def add(name : String, shape : Shape) : Nil
    @prototypes[name] = shape
  end

  # Clone the registered prototype identified by `name` and return it.
  def spawn(name : String) : Shape
    (@prototypes[name]? || raise "no prototype: #{name}").clone_shape
  end
end

# ---- Demonstration ----------------------------------------------------------
# NOTE: `lib` is a reserved Crystal keyword (used for C library bindings,
# e.g. `lib LibC`), so we name this variable `library`.
library = ShapeLibrary.new
library.add("default_star", Star.new(6, "red"))
library.add("small_circle", Circle.new(3))

s1 = library.spawn("default_star").as(Star)
s1.size = 12
puts s1.draw
puts library.spawn("default_star").as(Star).draw  # still 6, unchanged
puts library.spawn("small_circle").as(Circle).draw

# =============================================================================
# EXERCISE 1
#   Add a "big_circle" prototype and a user-friendly factory method
#   `spawn_and_scale(name, factor)` for Circle prototypes.
# SOLUTION 1:
#   lib.add("big_circle", Circle.new(40))
#   def spawn_and_scale(name : String, factor : Int32) : Shape
#     c = spawn(name)
#     raise "not a Circle" unless c.is_a?(Circle)
#     Circle.new(c.radius * factor)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Make the registry thread-safe (threading + Crystal).
# SOLUTION 2:
#   @lock = Mutex.new
#   def add(name, shape); @lock.synchronize { @prototypes[name] = shape }; end
#   def spawn(name)
#     @lock.synchronize { (@prototypes[name]? || raise "no prototype: #{name}").clone_shape }
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is Prototype more flexible than Factory Method when products are
#   runtime-configured (sizes, colors, etc.)?
# SOLUTION 3:
#   Factory Method fixes product configuration in code. Prototype's client
#   registers a fully configured instance at runtime; cloning reproduces
#   any state without knowing which class or what field values. Perfect for
#   "save this appearance" and content-authoring tools.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
