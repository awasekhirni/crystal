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
#   A weather station measures temperature. Multiple displays (phone,
#   dashboard, smart mirror) want to know when it changes. They subscribe.
#   Observer = subject notifies all subscribers automatically on change.
#
# SETUP:
#   crystal run 081_observer_weather.cr
# =============================================================================

# --- Observer interface ----------------------------------------------------
module Observer
  # Return the result of `update`.
  abstract def update(temp_c : Float64, humidity : Int32) : Nil
end

# --- Subject interface ----------------------------------------------------
module Subject
  # Return the result of `subscribe`.
  abstract def subscribe(o : Observer) : Nil
  # Return the result of `unsubscribe`.
  abstract def unsubscribe(o : Observer) : Nil
  # Return the result of `notify_observers`.
  abstract def notify_observers : Nil
end

# --- WeatherStation -------------------------------------------------------
class WeatherStation
  include Subject
  @observers = [] of Observer
  @temp_c : Float64 = 0.0
  @humidity : Int32 = 0

  # Return the result of `subscribe`.
  def subscribe(o : Observer) : Nil; @observers << o unless @observers.includes?(o); end
  # Return the result of `unsubscribe`.
  def unsubscribe(o : Observer) : Nil; @observers.delete(o); end
  # Return the result of `notify_observers`.
  def notify_observers : Nil; @observers.each(&.update(@temp_c, @humidity)); end

  # Return the result of `measurements=`.
  def measurements=(pair : Tuple(Float64, Int32)) : Nil
    @temp_c, @humidity = pair
    notify_observers  # crucial: notify on change
  end
end

# --- Concrete observers ---------------------------------------------------
class PhoneDisplay
  include Observer
  # Return the result of `update`.
  def update(temp_c : Float64, humidity : Int32) : Nil
    puts "[phone] #{temp_c}°C #{humidity}%"
  end
end

# Concrete class `DashboardDisplay`.
class DashboardDisplay
  include Observer
  @max : Float64 = -999.0
  # Return the result of `update`.
  def update(temp_c : Float64, humidity : Int32) : Nil
    @max = temp_c if temp_c > @max
    puts "[dashboard] now #{temp_c}°C, max #{@max}°C"
  end
end

# ---- Demonstration ----------------------------------------------------------
station = WeatherStation.new
phone = PhoneDisplay.new
dash  = DashboardDisplay.new
station.subscribe(phone)
station.subscribe(dash)

station.measurements = {20.5, 45}
station.measurements = {22.0, 40}
station.unsubscribe(phone)
station.measurements = {18.0, 60}

# =============================================================================
# EXERCISE 1
#   Add an AlertObserver that warns if temp > 30°C.
# SOLUTION 1:
#   class AlertObserver
#     include Observer
#     def update(temp_c, _)
#       puts "[alert] hot! #{temp_c}°C" if temp_c > 30
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add pull-style notification (observer asks station for state).
# SOLUTION 2:
#   Change Observer#update(source : WeatherStation); observer calls
#   source.temp_c. Makes Observer depend on the concrete subject, so use
#   sparingly — a Subject interface + payload stays cleaner.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why iterate over `@observers.dup` in notify?
# SOLUTION 3:
#   Observers may unsubscribe during notification. Iterating over the live
#   array would modify it while iterating (undefined/exception in Crystal).
#   Snapshotting via `.dup` makes notifications robust against reentrancy.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
