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
#   A TV remote has two independent "axes": the remote itself (basic, fancy,
#   gesture) and the device it controls (TV, radio, projector). Naively you'd
#   end up with 3 remotes × 3 devices = 9 subclasses. Bridge = keep one
#   abstraction (Remote) that uses one implementation (Device), so you can
#   mix them: 3 + 3 = 6 classes.
#
# SETUP:
#   crystal run 045_bridge_remote_control.cr
# =============================================================================

# --- Implementor: devices ------------------------------------------------
module Device
  # Return the result of `turn_on`.
  abstract def turn_on : String
  # Return the result of `turn_off`.
  abstract def turn_off : String
  # Return the result of `set_volume`.
  abstract def set_volume(level : Int32) : String
end

# Concrete class `TV`.
class TV
  include Device
  # Return the result of `turn_on`.
  def turn_on : String; "TV on"; end
  # Return the result of `turn_off`.
  def turn_off : String; "TV off"; end
  # Return the result of `set_volume`.
  def set_volume(level : Int32) : String; "TV vol #{level}"; end
end

# Concrete class `Radio`.
class Radio
  include Device
  # Return the result of `turn_on`.
  def turn_on : String; "Radio on"; end
  # Return the result of `turn_off`.
  def turn_off : String; "Radio off"; end
  # Return the result of `set_volume`.
  def set_volume(level : Int32) : String; "Radio vol #{level}"; end
end

# --- Abstraction: remotes ------------------------------------------------
class Remote
  def initialize(@device : Device); end

  # Return the result of `on`.
  def on : String; @device.turn_on; end
  # Return the result of `off`.
  def off : String; @device.turn_off; end

  # Return the result of `volume_up`.
  def volume_up(by : Int32 = 1) : String
    @device.set_volume(by)  # toy: absolute vol; real code tracks state
  end

  # Swap device at runtime.
  def device=(@device : Device); end
end

# "Refined" abstraction: adds mute/mute-toggle on top of Remote.
class AdvancedRemote < Remote
  # Return the result of `mute`.
  def mute : String
    @device.set_volume(0)
  end
end

# ---- Demonstration ----------------------------------------------------------
tv = TV.new
basic = Remote.new(tv)
puts basic.on
puts basic.volume_up(5)
basic.device = Radio.new
puts basic.on

adv = AdvancedRemote.new(TV.new)
puts adv.on
puts adv.mute

# =============================================================================
# EXERCISE 1
#   Add a Projector device without touching Remote classes.
# SOLUTION 1:
#   class Projector
#     include Device
#     def turn_on; "Projector on"; end
#     def turn_off; "Projector off"; end
#     def set_volume(l); "Projector vol #{l}"; end
#   end
#   # Usage: Remote.new(Projector.new) — works immediately.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "GestureRemote" abstraction that exposes `swipe(:up|:down)`.
# SOLUTION 2:
#   class GestureRemote < Remote
#     def swipe(dir : Symbol) : String
#       case dir
#       when :up   then volume_up(1)
#       when :down then volume_up(-1)
#       else raise "unknown swipe"
#       end
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare Bridge with Adapter: they look similar structurally. What differs?
# SOLUTION 3:
#   Adapter: after-the-fact. Two incompatible existing interfaces, one
#   adapter bridges them. Bridge: designed-in. Two independent dimensions
#   are abstracted separately from the start, so they can vary independently.
#   If you're "adapting" something you designed, it's probably Bridge.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
