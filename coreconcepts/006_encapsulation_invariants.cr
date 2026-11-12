# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed,Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: Encapsulation lets the class protect its own rules (invariants).
# A thermostat has a "min" and "max". No matter what buttons you press, the temperature must always stay between them.
#
#
class Thermostat
  MIN = 10.0
  MAX = 30.0

  @target : Float64

  def initialize(@target : Float64 = 20.0)
    validate!(@target)
  end

  #Read-only accessor to keep external code from bypassing validation
  getter target

  def target=(value : Float64) : Float64
    validate!(value)
    @target = value
  end

  #clamp here is similar to range it should be between min and max range
  def increase(by : Float64 =1.0) : Float64
    self.target = (@target + by).clamp(MIN,MAX)
  end

  def decrease(by : Float64 =1.0) : Float64
    self.target = (@target - by).clamp(MIN,MAX)
  end

  private def validate!(value : Float64)
    unless MIN <= value <= MAX
      raise ArgumentError.new("target must be within #{MIN}..#{MAX}, got #{value}")
    end
  end
end


# ---- Execution ----------------------------------------------------------
t = Thermostat.new
puts t.increase(5.0)
puts t.decrease(50.0)  # clamped to MIN
begin
  t.target = 100.0
rescue ex
  puts "Rejected: #{ex.message}"
end

# =============================================================================
# EXERCISE 1
#   Add a `presets` hash (e.g., {"home" => 21.0, "away" => 15.0}) and an
#   `apply_preset(name : String)` method that respects the invariant.
# SOLUTION 1:
#   PRESETS = {"home" => 21.0, "away" => 15.0}
#   def apply_preset(name : String)
#     self.target = PRESETS.fetch(name) { raise "unknown preset" }
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "hysteresis" rule: you can't set the same value twice in a row.
# SOLUTION 2:
#   In target=: return @target if value == @target
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Make validate! report *why* — too high vs too low.
# SOLUTION 3:
#   raise "too low" if value < MIN; raise "too high" if value > MAX
# =============================================================================
