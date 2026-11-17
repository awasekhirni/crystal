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
#   Watching a movie involves: dimming lights, turning on projector, lowering
#   screen, turning on receiver, setting input, pressing play. A "facade"
#   gives you one button: "movie night." It doesn't replace the components —
#   it just orchestrates them.
#
# SETUP:
#   crystal run 055_facade_home_theater.cr
# =============================================================================

# Concrete class `Lights`.
class Lights
  # Return the result of `dim`.
  def dim(level : Int32) : String; "lights dimmed to #{level}%"; end
  # Return the result of `on`.
  def on : String; "lights on"; end
end

# Concrete class `Projector`.
class Projector
  # Return the result of `on`.
  def on : String; "projector on"; end
  # Return the result of `set_input`.
  def set_input(src : String) : String; "projector input=#{src}"; end
  # Return the result of `off`.
  def off : String; "projector off"; end
end

# Concrete class `Screen`.
class Screen
  # Return the result of `lower`.
  def lower : String; "screen lowered"; end
  # Return the result of `raise_screen`.
  def raise_screen : String; "screen raised"; end
end

# Concrete class `Receiver`.
class Receiver
  # Return the result of `on`.
  def on : String; "receiver on"; end
  # Return the result of `set_input`.
  def set_input(src : String) : String; "receiver input=#{src}"; end
  # Return the result of `off`.
  def off : String; "receiver off"; end
end

# Concrete class `Player`.
class Player
  # Return the result of `play`.
  def play : String; "movie playing"; end
  # Return the result of `stop`.
  def stop : String; "movie stopped"; end
end

# --- Facade: hides the orchestration ---------------------------------------
class HomeTheaterFacade
  def initialize
    @lights   = Lights.new
    @projector = Projector.new
    @screen   = Screen.new
    @receiver = Receiver.new
    @player   = Player.new
  end

  # Return the result of `movie_night`.
  def movie_night : Nil
    puts @lights.dim(20)
    puts @screen.lower
    puts @projector.on
    puts @projector.set_input("dvd")
    puts @receiver.on
    puts @receiver.set_input("dvd")
    puts @player.play
  end

  # Return the result of `end_movie`.
  def end_movie : Nil
    puts @player.stop
    puts @receiver.off
    puts @projector.off
    puts @screen.raise_screen
    puts @lights.on
  end
end

# ---- Demonstration ----------------------------------------------------------
facade = HomeTheaterFacade.new
facade.movie_night
puts "---"
facade.end_movie

# =============================================================================
# EXERCISE 1
#   Add a "music night" facade method that skips the projector.
# SOLUTION 1:
#   def music_night : Nil
#     puts @lights.dim(40)
#     puts @receiver.on
#     puts @receiver.set_input("bluetooth")
#     puts @player.play
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Explain why exposing the components directly is sometimes preferred.
# SOLUTION 2:
#   A facade is a convenience — it shouldn't become a bottleneck or hide
#   power features. Advanced users may want direct component access
#   (e.g., projector.set_input("pc") while receiver set to dvd). Expose both:
#   facade for the common flows, accessors for granular control.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare Facade to Adapter and to Mediator in one sentence each.
# SOLUTION 3:
#   Facade: one simplified entry point to many components (convenience).
#   Adapter: translate between two incompatible interfaces (compatibility).
#   Mediator: hub for peer-to-peer communication (decoupling many peers).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
