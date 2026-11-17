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
#   Two ways to use an adapter dongle: (a) glue the dongle permanently onto
#   the plug (class adapter via inheritance), or (b) carry a portable dongle
#   you plug into anything (object adapter via composition). Crystal favors
#   (b) because you can't inherit from two classes at once, and composition
#   is more flexible.
#
# SETUP:
#   crystal run 042_adapter_class_vs_object.cr
# =============================================================================

# --- Target interface -------------------------------------------------------
module TemperatureSensor
  # Return the result of `celsius`.
  abstract def celsius : Float64
end

# --- Adaptee (legacy, returns Fahrenheit) -----------------------------------
class LegacyFahrenheitSensor
  # Return the result of `read_fahrenheit`.
  def read_fahrenheit : Float64; 98.6; end
end

# --- Object adapter (composition) ------------------------------------------
class FahrenheitSensorAdapter
  include TemperatureSensor
  def initialize(@sensor : LegacyFahrenheitSensor); end
  # Return the result of `celsius`.
  def celsius : Float64
    (@sensor.read_fahrenheit - 32.0) * 5.0 / 9.0
  end
end

# --- Client -----------------------------------------------------------------
def report(sensor : TemperatureSensor) : Nil
  puts "Temp: #{sensor.celsius.round(2)}°C"
end

# ---- Demonstration ----------------------------------------------------------
report(FahrenheitSensorAdapter.new(LegacyFahrenheitSensor.new))

# =============================================================================
# EXERCISE 1
#   Add a KelvinSensor that adapts a "read_kelvin" API.
# SOLUTION 1:
#   class LegacyKelvinSensor
#     def read_kelvin : Float64; 300.0; end
#   end
#   class KelvinSensorAdapter
#     include TemperatureSensor
#     def initialize(@s : LegacyKelvinSensor); end
#     def celsius : Float64; @s.read_kelvin - 273.15; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Write a "class adapter" of the Celsius interface without a second
#   inheritance — explain why it's not idiomatic in Crystal.
# SOLUTION 2:
#   Crystal allows only single inheritance plus module inclusion. A "class
#   adapter" would require inheriting from both the target and the adaptee,
#   which is impossible in single-inheritance languages. You can mimic it
#   with a class that has the adaptee as a field — which is just composition
#   again. Hence object adapter is the idiomatic form.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Give one scenario where you'd still prefer inheritance in an adapter.
# SOLUTION 3:
#   When the adaptee's class is itself abstract and subclasses it to override
#   some behaviors — i.e., when the adapter is a specialized adaptee. Even
#   then, use the object adapter unless you specifically need polymorphic
#   substitution on the adaptee side too.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
