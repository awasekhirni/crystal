# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed,Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: Abstractions are conceptual idea or concept that lets us create
# a concrete objects from. A shape is concept, while circle and square are
# real objects but are of type shape. Shape is an abstraction.
#

abstract class Shape
  abstract def area : Float64
  abstract def name : String


  #concrete behaviour shared by all shapes, it is built on the abstract contract
  def describe : String
     "#{name} with area #{area.round(2)}"
  end
end


#concrete classes

class Circle < Shape
  def initialize(@radius : Float64)
    raise ArgumentError.new("radius must be > 0") unless @radius > 0
  end

  def area : Float64
    Math::PI * @radius **2
  end

  def name : String
    "Circle"
  end
end


# class rectangle
class Rectangle < Shape
  def initialize(@width : Float64, @height : Float64)
    raise ArgumentError.new("dimensions must be > 0") unless @width > 0 && @height > 0
  end

  def area : Float64
    @width * @height
  end

  def name : String
    "Rectangle"
  end
end


# Client code depends only on the abstraction, never on concrete classes.
def print_report(shapes : Array(Shape))
  shapes.each { |s| puts s.describe }
end

# ---- Execution ----------------------------------------------------------
print_report([Circle.new(2.0), Rectangle.new(3.0, 4.0)])

# =============================================================================
# EXERCISE 1
#   Add a Triangle shape.
# SOLUTION 1:
#   class Triangle < Shape
#     def initialize(@a : Float64, @b : Float64, @c : Float64); end
#     def name; "Triangle"; end
#     def area : Float64
#       s = (@a + @b + @c) / 2.0
#       Math.sqrt(s * (s-@a) * (s-@b) * (s-@c))
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `perimeter` abstract method and implement for each shape.
# SOLUTION 2:
#   In Shape: abstract def perimeter : Float64
#   Circle: 2 * Math::PI * @radius
#   Rectangle: 2 * (@width + @height)
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compute the total area of a heterogeneous Array(Shape) without if/elsif.
# SOLUTION 3:
#   shapes.sum(&.area)   # polymorphism does the work
# =============
