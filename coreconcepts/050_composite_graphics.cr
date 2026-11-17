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
#   A drawing is made of shapes, and "groups of shapes" that can themselves
#   be grouped. Moving a group should move everything inside. Composite
#   makes group and shape behave identically for operations like move, draw,
#   and bounding_box.
#
# SETUP:
#   crystal run 050_composite_graphics.cr
# =============================================================================

# Module `Graphic`.
module Graphic
  # Translate this object by (dx, dy).  Returns Nil.
  abstract def move(dx : Float64, dy : Float64) : Nil
  # Return a short String describing the drawn shape/node.
  abstract def draw : String
  # Return the bounding box as {x, y, w, h}.
  abstract def bounds : Tuple(Float64, Float64, Float64, Float64)  # x, y, w, h
end

# Concrete class `Dot`.
class Dot
  include Graphic
  def initialize(@x : Float64, @y : Float64); end
  # Translate this object by (dx, dy).  Returns Nil.
  def move(dx, dy) : Nil; @x += dx; @y += dy; end
  # Return a short String describing the drawn shape/node.
  def draw : String; "Dot @#{@x},#{@y}"; end
  # Return the bounding box as {x, y, w, h}.
  def bounds : Tuple(Float64, Float64, Float64, Float64); {@x, @y, 0.0, 0.0}; end
end

# Concrete class `Rectangle`.
class Rectangle
  include Graphic
  def initialize(@x : Float64, @y : Float64, @w : Float64, @h : Float64); end
  # Translate this object by (dx, dy).  Returns Nil.
  def move(dx, dy) : Nil; @x += dx; @y += dy; end
  # Return a short String describing the drawn shape/node.
  def draw : String; "Box #{@x},#{@y} #{@w}x#{@h}"; end
  # Return the bounding box as {x, y, w, h}.
  def bounds : Tuple(Float64, Float64, Float64, Float64); {@x, @y, @w, @h}; end
end

# Concrete class `Group`.
class Group
  include Graphic
  @children = [] of Graphic
  # Add an element and return self for chaining.
  def add(g : Graphic) : Group; @children << g; self; end
  # Translate this object by (dx, dy).  Returns Nil.
  def move(dx, dy) : Nil; @children.each(&.move(dx, dy)); end
  # Return a short String describing the drawn shape/node.
  def draw : String; @children.map(&.draw).join(" | "); end
  # Return the bounding box as {x, y, w, h}.
  def bounds : Tuple(Float64, Float64, Float64, Float64)
    xs = @children.map(&.bounds)
    min_x = xs.min_of { |b| b[0] }
    min_y = xs.min_of { |b| b[1] }
    max_x = xs.max_of { |b| b[0] + b[2] }
    max_y = xs.max_of { |b| b[1] + b[3] }
    {min_x, min_y, max_x - min_x, max_y - min_y}
  end
end

# ---- Demonstration ----------------------------------------------------------
# NOTE: the primitive box class was renamed `Rectangle` because Crystal's
# prelude already defines a generic `Box(T)` for typed pointer wrappers;
# reopening it as a non-generic class triggers a confusing "@object" error.
g = Group.new
g.add(Dot.new(1.0, 1.0)).add(Rectangle.new(2.0, 2.0, 4.0, 4.0))
puts g.draw
g.move(10, 20)
puts g.draw
puts g.bounds

# =============================================================================
# EXERCISE 1
#   Add a "circle" primitive.
# SOLUTION 1:
#   class Circle
#     include Graphic
#     def initialize(@x, @y, @r); end
#     def move(dx, dy) : Nil; @x += dx; @y += dy; end
#     def draw; "Circle @#{@x},#{@y} r#{@r}"; end
#     def bounds; {@x - @r, @y - @r, @r * 2, @r * 2}; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `scale(factor)` operation to Graphic. Explain the design impact.
# SOLUTION 2:
#   Add `abstract def scale(factor)` and implement per type (Dot: no-op for
#   position, but maybe multiply radius; Box: multiply w/h; Group: recurse).
#   Composite naturally distributes the operation to all children.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   A "group" of one is sometimes needed for symmetry. Any downside?
# SOLUTION 3:
#   Extra indirection: memory + one extra method dispatch per operation.
#   In hot loops (games, rendering), collapsing single-child groups helps.
#   Keep the uniformity in the domain API; optimize inside the implementation
#   if needed (e.g., store unwrapped if children.size == 1).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
