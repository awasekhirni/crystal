# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:there are two ways to build a robot first approach is robot is a machine (inheritance) and the second approach
# is robot has a brain and has a motor (composition). option b lets you swap parts which usually the more flexible choice
#
#

#--- inheritance approach
abstract class Machine
  abstract def run : String
end

class DrillMachine < Machine
  def run : String; "Drill spinning"; end
end

# --- composition path
module Motor
  abstract def spin : String
end


class ElectricMotor
  include Motor
  def spin : String; "electric spin"; end
end


class SteamMotor
  include Motor
  def spin : String; "steam spin"; end
end


class Robot
  #Has a motor; motor can be swapped at runtime.
  def initialize(@motor : Motor); end
  def run : String; "Robot runnig: #{@motor.spin}"; end
  def motor=(@motor : Motor); end
end

# ---- Demonstration ----------------------------------------------------------
puts DrillMachine.new.run        # inheritance
r = Robot.new(ElectricMotor.new)
puts r.run
r.motor = SteamMotor.new          # composition allows swapping
puts r.run

# =============================================================================
# EXERCISE 1
#   Add a RoboDrill that inherits DrillMachine AND uses composition.
# SOLUTION 1:
#   class RoboDrill < DrillMachine
#     def initialize(@motor : Motor); end
#     def run : String; "#{super} + #{@motor.spin}"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a FakeMotor that returns "fake spin" for use in tests.
# SOLUTION 2:
#   class FakeMotor
#     include Motor
#     def spin : String; "fake spin"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare the two designs in a few sentences as a comment.
# SOLUTION 3:
#   Inheritance models "is-a" (a DrillMachine IS-A Machine). It's fine for
#   genuine hierarchies, but each new dimension (motor type, control system)
#   forces subclassing explosions. Composition models "has-a" and lets us
#   swap parts, combine behaviors, and inject test doubles. Prefer
#   composition when behavior varies independently of identity.
# =============================================================================
