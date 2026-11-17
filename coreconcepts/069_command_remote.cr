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
#   A TV remote's buttons don't know what "volume up" or "channel 5" really
#   does — they just hand a "command" object to the TV. Command pattern =
#   encapsulate a request (receiver + action + parameters) as an object.
#
# SETUP:
#   crystal run 069_command_remote.cr
# =============================================================================

# --- Receiver ---------------------------------------------------------------
class TV
  property channel = 1, volume = 10
  # Return the result of `on`.
  def on : String; "TV on"; end
  # Return the result of `off`.
  def off : String; "TV off"; end
  # Return the result of `set_channel`.
  def set_channel(c : Int32) : String; @channel = c; "channel=#{c}"; end
  # Return the result of `set_volume`.
  def set_volume(v : Int32) : String; @volume = v; "volume=#{v}"; end
end

# --- Command interface ----------------------------------------------------
module Command
  # Return the result of `execute`.
  abstract def execute : String
end

# --- Concrete commands ----------------------------------------------------
class TurnOnCommand
  include Command
  def initialize(@tv : TV); end
  # Return the result of `execute`.
  def execute : String; @tv.on; end
end

# Concrete class `TurnOffCommand`.
class TurnOffCommand
  include Command
  def initialize(@tv : TV); end
  # Return the result of `execute`.
  def execute : String; @tv.off; end
end

# Concrete class `SetChannelCommand`.
class SetChannelCommand
  include Command
  def initialize(@tv : TV, @channel : Int32); end
  # Return the result of `execute`.
  def execute : String; @tv.set_channel(@channel); end
end

# Concrete class `SetVolumeCommand`.
class SetVolumeCommand
  include Command
  def initialize(@tv : TV, @volume : Int32); end
  # Return the result of `execute`.
  def execute : String; @tv.set_volume(@volume); end
end

# --- Invoker: a button that holds a command ------------------------------
class Button
  def initialize(@command : Command); end
  # Return the result of `command=`.
  def command=(@command : Command); end
  # Return the result of `press`.
  def press : String; @command.execute; end
end

# ---- Demonstration ----------------------------------------------------------
tv = TV.new
on_btn    = Button.new(TurnOnCommand.new(tv))
ch5_btn   = Button.new(SetChannelCommand.new(tv, 5))
vol20_btn = Button.new(SetVolumeCommand.new(tv, 20))

puts on_btn.press
puts ch5_btn.press
puts vol20_btn.press
puts "TV state: ch=#{tv.channel}, vol=#{tv.volume}"

# =============================================================================
# EXERCISE 1
#   Add a MacroCommand that runs several commands in sequence.
# SOLUTION 1:
#   class MacroCommand
#     include Command
#     def initialize(@cmds : Array(Command)); end
#     def execute : String
#       @cmds.map(&.execute).join(" | ")
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add "channel up" and "volume up" (relative commands).
# SOLUTION 2:
#   class ChannelUpCommand
#     include Command
#     def initialize(@tv : TV); end
#     def execute; @tv.set_channel(@tv.channel + 1); end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is "put command objects on a button" better than a case on :on/:off?
# SOLUTION 3:
#   Commands are first-class: you can queue them, log them, undo them, group
#   them (MacroCommand), or serialize them. A `case` on symbols grows with
#   each new action (OCP violation) and can't be handed around. Command
#   decouples invoker (button) from receiver (TV) and turns behavior into
#   data.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
