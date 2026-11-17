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
#   A painter has a rule book: "to paint a circle, do X; to paint a square,
#   do Y." Every new shape means rewriting the rule book. OCP says: let
#   each shape know how to draw itself, or use visitor-style objects — but
#   don't keep editing the central renderer.
#
# SETUP:
#   crystal run 012_solid_ocp_shapes_renderer.cr
# =============================================================================

# --- Bad: central renderer knows every shape --------------------------------
#
#   def render(shape)
#     case shape
#     when Circle then "drawing circle"
#     when Square then "drawing square"
#     end
#   end
#   # New shape => edit render(). Violates OCP.

# --- Good: each shape owns its rendering -------------------------------------
module Renderable
  # Render the receiver to a String representation.
  abstract def render : String
end

# Concrete class `Circle`.
class Circle
  include Renderable
  def initialize(@r : Float64); end
  # Render the receiver to a String representation.
  def render : String; "Circle r=#{@r}"; end
end

# Concrete class `Square`.
class Square
  include Renderable
  def initialize(@side : Float64); end
  # Render the receiver to a String representation.
  def render : String; "Square s=#{@side}"; end
end

# Renderer is closed for modification: any Renderable works.
class Canvas
  # Return the result of `render_all`.
  def render_all(shapes : Array(Renderable)) : Nil
    shapes.each { |s| puts s.render }
  end
end

# ---- Demonstration ----------------------------------------------------------
Canvas.new.render_all([Circle.new(1.0), Square.new(2.0)] of Renderable)

# =============================================================================
# EXERCISE 1
#   Add a Triangle without touching Canvas.
# SOLUTION 1:
#   class Triangle
#     include Renderable
#     def initialize(@a : Float64, @b : Float64, @c : Float64); end
#     def render : String; "Triangle #{@a}/#{@b}/#{@c}"; end
#   end
#   Canvas.new.render_all([Triangle.new(3,4,5)] as Array(Renderable))
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a second renderer (SVG) via a Visitor instead of editing shapes.
# SOLUTION 2:
#   module ShapeVisitor
#     abstract def visit(circle : Circle) : String
#     abstract def visit(square : Square) : String
#   end
#   # Each shape gains `accept(v : ShapeVisitor)`:
#   #   def accept(v); v.visit(self); end
#   # SVGVisitor implements the module and returns SVG strings. The shape
#   # classes still need one new method `accept` — that's the minimal
#   # extension required for the Visitor pattern.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain in one comment why the first approach is a hidden OCP violator.
# SOLUTION 3:
#   Every new shape forces editing render() — a "closed" method. The
#   conditional keeps growing (a "switch statement smell"). Any existing
#   shape addition risks breaking unrelated branches, and callers must
#   rebuild to gain support for new shapes. Both symptoms vanish when
#   each shape implements Renderable itself.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
