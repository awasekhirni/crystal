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
#   A shape (circle, square) and a rendering backend (raster, vector). Four
#   combinations if you subclass naively. Bridge keeps shapes and renderers
#   independent — a shape holds a renderer and asks it to draw itself.
#
# SETUP:
#   crystal run 046_bridge_renderer.cr
# =============================================================================

# --- Implementor: Renderer ------------------------------------------------
module Renderer
  # Return the result of `draw_circle`.
  abstract def draw_circle(x : Float64, y : Float64, r : Float64) : String
  # Return the result of `draw_square`.
  abstract def draw_square(x : Float64, y : Float64, s : Float64) : String
end

# Concrete class `RasterRenderer`.
class RasterRenderer
  include Renderer
  # Return the result of `draw_circle`.
  def draw_circle(x, y, r) : String; "raster circle @#{x},#{y} r#{r}"; end
  # Return the result of `draw_square`.
  def draw_square(x, y, s) : String; "raster square @#{x},#{y} s#{s}"; end
end

# Concrete class `VectorRenderer`.
class VectorRenderer
  include Renderer
  # Return the result of `draw_circle`.
  def draw_circle(x, y, r) : String; "vector <circle cx=#{x} cy=#{y} r=#{r}/>"; end
  # Return the result of `draw_square`.
  def draw_square(x, y, s) : String; "vector <rect x=#{x} y=#{y} w=#{s} h=#{s}/>"; end
end

# --- Abstraction: Shape ---------------------------------------------------
abstract class Shape
  def initialize(@renderer : Renderer, @x : Float64, @y : Float64); end
  # Return a short String describing the drawn shape/node.
  abstract def draw : String
end

# Concrete class `Circle` -- extends Shape.
class Circle < Shape
  def initialize(r : Renderer, x : Float64, y : Float64, @radius : Float64)
    super(r, x, y)
  end
  # Return a short String describing the drawn shape/node.
  def draw : String; @renderer.draw_circle(@x, @y, @radius); end
end

# Concrete class `Square` -- extends Shape.
class Square < Shape
  def initialize(r : Renderer, x : Float64, y : Float64, @side : Float64)
    super(r, x, y)
  end
  # Return a short String describing the drawn shape/node.
  def draw : String; @renderer.draw_square(@x, @y, @side); end
end

# ---- Demonstration ----------------------------------------------------------
shapes : Array(Shape) = [
  Circle.new(VectorRenderer.new, 1.0, 2.0, 3.0),  # of Shape (typed below)
  Square.new(RasterRenderer.new, 4.0, 5.0, 6.0),  # of Shape (typed via array literal)
]
shapes.each { |s| puts s.draw }

# =============================================================================
# EXERCISE 1
#   Add a Triangle shape (uses draw_square? or extend Renderer?). Discuss.
# SOLUTION 1:
#   Extending Renderer with draw_triangle keeps concerns separate; the
#   alternative (Triangle approximated by two squares) is a hack. Add:
#     abstract def draw_triangle(x,y,base,height) : String
#   Implement in both renderers, then Triangle#draw calls it.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "SvgRenderer" backend. How many classes change?
# SOLUTION 2:
#   Just one new class. Existing shapes untouched; they take any Renderer.
#   This is the payoff of the Bridge: new axes multiply cheaply.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compute the class count for "4 shapes × 3 renderers" with and without
#   Bridge; explain the trend.
# SOLUTION 3:
#   Without Bridge: 4×3 = 12 subclasses (plus combinations when adding axes).
#   With Bridge: 4 shapes + 3 renderers = 7 classes. Cost grows additively,
#   not multiplicatively. The trend gets more dramatic as axes grow.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
