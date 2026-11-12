# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:Liskov substitution principles subclasses must respect their parents promises
# preconditions not strengthened, post conditions not weakend. if I promize all my shapes have a positive area
# then a shape with area=0 must not sneak in.
#

# contract: area is always > 0. every subclass must honor that.

abstract class PositiveShape
  abstract def area : Float64
end


class Rect < PositiveShape
  def initialize(@w : Float64, @h : Float64)
    raise ArgumentError.new("dims must be >0") unless @w > 0 && @h > 0
  end
  def area : Float64; @w * @h; end
end


#wrong approach LSP
# class DegenerateRect < Rect
#   def initialize; super(0.0,0.0); end #breaks the area > 0 contract
# end
#

class Segement
  def initialize(@length : Float64)
    raise ArgumentError.new("length must be >0") unless @length > 0
  end
  def length : Float64; @length; end
end

#client is allowed to assume area > 0

def smallest_area(shapes : Array(PositiveShape)) : Float64
  shapes.min_of(&.area)
end

#----------------------------------------------------------
puts smallest_area([Rect.new(2.0, 3.0), Rect.new(5.0, 1.0).as(PositiveShape)])

# =============================================================================
# EXERCISE 1
#   Add a Circle and confirm LSP holds (area > 0 for r > 0).
# SOLUTION 1:
#   class Circle < PositiveShape
#     def initialize(@r : Float64)
#       raise ArgumentError.new("r must be > 0") unless @r > 0
#     end
#     def area : Float64; Math::PI * @r ** 2; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Prove the invariant with a tiny runtime assertion helper.
# SOLUTION 2:
#   def assert_positive(shapes : Array(PositiveShape))
#     shapes.each do |s|
#       raise "LSP broken: #{s.class} area=#{s.area}" unless s.area > 0
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain the LSP defect in the "DegenerateRect" snippet.
# SOLUTION 3:
#   Its postcondition (area > 0) does not hold, so any caller that trusted
#   the abstract promise (e.g., used area in a denominator) could crash. The
#   correct fix is to model it as a different type (Segment) rather than
#   inherit from Rect and break the contract.
# ================================================
