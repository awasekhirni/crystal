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
#   Planes don't talk to each other — they talk to the control tower. The
#   tower decides who lands when. Mediator = central controller so peers
#   don't have to know about each other.
#
# SETUP:
#   crystal run 076_mediator_air_traffic.cr
# =============================================================================

# --- Mediator: Control Tower ----------------------------------------------
class ControlTower
  @runway_busy = false
  @queue = [] of Aircraft

  # Return the result of `request_landing`.
  def request_landing(plane : Aircraft) : Nil
    if @runway_busy
      puts "#{plane.id}: queued for landing"
      @queue << plane
    else
      @runway_busy = true
      puts "#{plane.id}: cleared to land"
    end
  end

  # Return the result of `finished_landing`.
  def finished_landing(plane : Aircraft) : Nil
    @runway_busy = false
    puts "#{plane.id}: landed, runway free"
    if next_plane = @queue.shift?
      @runway_busy = true
      puts "#{next_plane.id}: cleared to land (from queue)"
    end
  end
end

# --- Colleague: Aircraft ---------------------------------------------------
class Aircraft
  getter id : String
  def initialize(@id : String, @tower : ControlTower); end
  # Return the result of `land`.
  def land : Nil; @tower.request_landing(self); end
  # Return the result of `landed`.
  def landed : Nil; @tower.finished_landing(self); end
end

# ---- Demonstration ----------------------------------------------------------
tower = ControlTower.new
a = Aircraft.new("AA1", tower)
b = Aircraft.new("BA2", tower)
c = Aircraft.new("CA3", tower)

a.land
b.land
c.land
a.landed     # BA2 lands next
b.landed     # CA3 lands next
c.landed

# =============================================================================
# EXERCISE 1
#   Add "emergency" landing that jumps the queue.
# SOLUTION 1:
#   def emergency(plane)
#     if @runway_busy
#       @queue.unshift(plane)  # to the front
#       puts "#{plane.id}: emergency — priority queued"
#     else
#       @runway_busy = true
#       puts "#{plane.id}: EMERGENCY cleared to land"
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add "holding pattern" status (planes in queue print next when polled).
# SOLUTION 2:
#   def status
#     @queue.each_with_index.map { |p, i| "#{i + 1}. #{p.id}" }
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   What breaks if planes called each other directly for runway access?
# SOLUTION 3:
#   They'd need to know all other planes in range (impossible in real life
#   and O(n²) in code), implement protocol logic themselves, and deadlock
#   each other easily. Mediator centralizes policy in one place — cheaper,
#   auditable, and easy to change ("no landings from 22:00-06:00").
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
