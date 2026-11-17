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
#   You have a zoo of shapes (circle, square). You want to add operations
#   (area, perimeter, SVG export) without editing each shape. Visitor = add
#   operations as visitors while keeping shapes closed. Double dispatch:
#   `shape.accept(visitor)` calls `visitor.visit_shape(...)`.
#
# SETUP:
#   crystal run 093_visitor_shapes.cr
# =============================================================================

# --- Visitor interface -----------------------------------------------------
# Forward declaration not needed in Crystal; we reference concrete types.
module ShapeVisitor
  # Visit a Circle and return the computed String.
  abstract def visit_circle(c : Circle) : String
  # Visit a Square and return the computed String.
  abstract def visit_square(s : Square) : String
end

# --- Element interface -----------------------------------------------------
module Shape
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  abstract def accept(visitor : ShapeVisitor) : String
end

# --- Concrete elements -----------------------------------------------------
class Circle
  include Shape
  getter radius : Float64
  def initialize(@radius : Float64); end
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  def accept(v : ShapeVisitor) : String; v.visit_circle(self); end
end

# Concrete class `Square`.
class Square
  include Shape
  getter side : Float64
  def initialize(@side : Float64); end
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  def accept(v : ShapeVisitor) : String; v.visit_square(self); end
end

# --- Concrete visitors ----------------------------------------------------
class AreaVisitor
  include ShapeVisitor
  # Visit a Circle and return the computed String.
  def visit_circle(c : Circle) : String; "area Circle=#{Math::PI * c.radius ** 2}"; end
  # Visit a Square and return the computed String.
  def visit_square(s : Square) : String; "area Square=#{s.side ** 2}"; end
end

# Concrete class `PerimeterVisitor`.
class PerimeterVisitor
  include ShapeVisitor
  # Visit a Circle and return the computed String.
  def visit_circle(c : Circle) : String; "perim Circle=#{2 * Math::PI * c.radius}"; end
  # Visit a Square and return the computed String.
  def visit_square(s : Square) : String; "perim Square=#{4 * s.side}"; end
end

# ---- Demonstration ----------------------------------------------------------
shapes : Array(Shape) = [Circle.new(2.0), Square.new(3.0)] of Shape
[AreaVisitor.new, PerimeterVisitor.new].each do |v|
  shapes.each { |s| puts s.accept(v) }
end

# =============================================================================
# EXERCISE 1
#   Add an "SVG export" visitor.
# SOLUTION 1:
#   class SvgVisitor
#     include ShapeVisitor
#     def visit_circle(c); "<circle r=#{c.radius}/>"; end
#     def visit_square(s); "<rect w=#{s.side} h=#{s.side}/>"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a Triangle shape. What must change?
# SOLUTION 2:
#   Both ShapeVisitor implementations must add visit_triangle (else Crystal
#   complains they don't implement the abstract method). This is the classic
#   Visitor trade-off: adding shapes touches every visitor; adding visitors
#   touches nothing else.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why does `accept(visitor)` need to be inside each element?
# SOLUTION 3:
#   Double dispatch: first call picks the element's `accept` (via the
#   element's runtime type), which then calls `visitor.visit_` on the
#   visitor — passing `self` typed as the concrete element. Crystal resolves
#   both types at compile time; without this indirection, the visitor would
#   need runtime `case`/`is_a?` checks, defeating the pattern.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
