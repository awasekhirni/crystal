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
#   A traffic light has states: Red → Green → Yellow → Red. Each state decides
#   what the next state is. A state machine = object changes behavior based
#   on its current state, implemented by swapping a state object.
#
# SETUP:
#   crystal run 084_state_traffic_light.cr
# =============================================================================

# --- State interface -------------------------------------------------------
module LightState
  # Return the human-readable name of this state/object.
  abstract def name : String
  # Return the result of `next_state`.
  abstract def next_state : LightState
  # Return true if `can_go` holds.
  abstract def can_go? : Bool
end

# --- Concrete states ------------------------------------------------------
class Red
  include LightState
  # Return the human-readable name of this state/object.
  def name : String; "RED"; end
  # Return the result of `next_state`.
  def next_state : LightState; Green.new; end
  # Return true if `can_go` holds.
  def can_go? : Bool; false; end
end

# Concrete class `Green`.
class Green
  include LightState
  # Return the human-readable name of this state/object.
  def name : String; "GREEN"; end
  # Return the result of `next_state`.
  def next_state : LightState; Yellow.new; end
  # Return true if `can_go` holds.
  def can_go? : Bool; true; end
end

# Concrete class `Yellow`.
class Yellow
  include LightState
  # Return the human-readable name of this state/object.
  def name : String; "YELLOW"; end
  # Return the result of `next_state`.
  def next_state : LightState; Red.new; end
  # Return true if `can_go` holds.
  def can_go? : Bool; false; end
end

# --- Context --------------------------------------------------------------
class TrafficLight
  def initialize(@state : LightState = Red.new); end
  # Return the result of `state`.
  def state : LightState; @state; end

  # Return the result of `advance`.
  def advance : String
    previous = @state.name
    @state = @state.next_state
    "#{previous} -> #{@state.name}"
  end

  # Return true if `can_go` holds.
  def can_go? : Bool; @state.can_go?; end
end

# ---- Demonstration ----------------------------------------------------------
light = TrafficLight.new
4.times { puts light.advance }
puts "can_go? #{light.can_go?}"   # currently GREEN → true

# =============================================================================
# EXERCISE 1
#   Add a "Flashing" state used when the light is broken.
# SOLUTION 1:
#   class Flashing
#     include LightState
#     def name; "FLASHING"; end
#     def next_state; self; end   # stays flashing until fixed
#     def can_go?; false; end
#   end
#   # In context: `def broken!; @state = Flashing.new; end`
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Time-based transitions: red for 30s, green 25s, yellow 5s.
# SOLUTION 2:
#   Add `duration : Int32` to each state, and in TrafficLight track a timer.
#   `advance_if_timeout` consults `@state.duration` before transitioning.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare with a `case` statement over `:red | :green | :yellow`.
# SOLUTION 3:
#   The `case` concentrates all transitions in one place (edit for every
#   change — OCP violation), difficult to extend (emergency, pedestrian
#   modes), and invites scattered conditionals. State classes localize
#   each behavior, allow easy new states, and make impossible states
#   impossible (no `:purple` symbol sneaking in).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
