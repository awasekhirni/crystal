# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed,Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: composition defines "has a " relationship. A car is composed of an engine and many other things.
# It has an engine. When the car starts, it asks the engine to start. It often more flexible that "is a"(inheritance ) relationship
#
#
module Engine
  abstract def start : String
  abstract def stop : String
end

# defining type of engine
class GasEngine
  include Engine
  def start : String; "Vroom Vroom (gas)"; end
  def stop : String; "Gas engine off"; end
end

# defining type of engine
class ElectricEngine
  include Engine
  def start : String; " Whirr (electric)"; end
  def stop : String; "Electric engine off"; end
end


# Car *composes* an Engine — it does not inherit from one.
# This lets us swap engines at runtime without changing Car.
class Car
  def initialize(@engine : Engine); end

  # Delegation: Car exposes start/stop, forwards to engine.
  def start : String; @engine.start; end
  def stop  : String; @engine.stop;  end

  # Composition allows runtime swapping (a form of Strategy).
  def engine=(@engine : Engine); end
end

# ---- execution ----------------------------------------------------------
car = Car.new(GasEngine.new)
puts car.start
puts car.stop
car.engine = ElectricEngine.new
puts car.start
puts car.stop

# =============================================================================
# EXERCISE 1
#   Add a HybridEngine that alternates gas/electric each start.
# SOLUTION 1:
#   class HybridEngine
#     include Engine
#     @count = 0
#     def start : String
#       @count += 1
#       @count.odd? ? "Gas start" : "Electric start"
#     end
#     def stop : String; "Hybrid off"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `diagnose` method on Car that delegates to engine only if the
#   engine responds to :diagnose (duck typing + respond_to?).
# SOLUTION 2:
#   def diagnose : String
#     @engine.responds_to?(:diagnose) ? @engine.diagnose : "No diagnostics"
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is composition preferable here? Write a short answer as a comment.
# SOLUTION 3:
#   Inheritance would force Car to be an Engine subclass, mixing "is-a"
#   with "has-a" and preventing runtime swaps. Composition gives us
#   flexible wiring, testability (inject a FakeEngine), and follow-open/
#   closed for new engines without touching Car.
# =============================================================================
#
