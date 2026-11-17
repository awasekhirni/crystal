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
#   A media player can play MP3, WAV, OGG… and it doesn't need to be rebuilt
#   to support each new format. Each "format handler" is a plug-in creator
#   that produces a matching player. The app just asks the registry.
#
# SETUP:
#   crystal run 025_factory_method_plugin.cr
# =============================================================================

# --- Products ---------------------------------------------------------------
module Player
  # Return the result of `play`.
  abstract def play(track : String) : String
end

# Concrete class `Mp3Player`.
class Mp3Player
  include Player
  # Return the result of `play`.
  def play(track : String) : String; "MP3: #{track}"; end
end

# Concrete class `WavPlayer`.
class WavPlayer
  include Player
  # Return the result of `play`.
  def play(track : String) : String; "WAV: #{track}"; end
end

# Concrete class `OggPlayer`.
class OggPlayer
  include Player
  # Return the result of `play`.
  def play(track : String) : String; "OGG: #{track}"; end
end

# --- Abstract creator -------------------------------------------------------
abstract class FormatHandler
  # Return the result of `create_player`.
  abstract def create_player : Player
  # Return the result of `play`.
  def play(track : String) : String; create_player.play(track); end
end

# --- Concrete creators ------------------------------------------------------
class Mp3Handler < FormatHandler
  # Return the result of `create_player`.
  def create_player : Player; Mp3Player.new; end
end

# Concrete class `WavHandler` -- extends FormatHandler.
class WavHandler < FormatHandler
  # Return the result of `create_player`.
  def create_player : Player; WavPlayer.new; end
end

# Concrete class `OggHandler` -- extends FormatHandler.
class OggHandler < FormatHandler
  # Return the result of `create_player`.
  def create_player : Player; OggPlayer.new; end
end

# --- Plugin registry (composition, not case statements) --------------------
class PlayerRegistry
  @handlers = {} of String => FormatHandler

  # Register `service` under `name`.  Returns Nil.
  def register(extension : String, handler : FormatHandler) : Nil
    @handlers[extension.downcase] = handler
  end

  # Return the result of `player_for`.
  def player_for(filename : String) : Player
    ext = File.extname(filename).lchop('.').downcase
    handler = @handlers[ext]? || raise "unsupported: .#{ext}"
    handler.create_player
  end
end

# ---- Demonstration ----------------------------------------------------------
registry = PlayerRegistry.new
registry.register("mp3", Mp3Handler.new)
registry.register("wav", WavHandler.new)
registry.register("ogg", OggHandler.new)

puts registry.player_for("song.mp3").play("song.mp3")
puts registry.player_for("song.WAV").play("song.WAV")
puts registry.player_for("song.ogg").play("song.ogg")
begin
  registry.player_for("song.flac")
rescue ex
  puts "Error: #{ex.message}"
end

# =============================================================================
# EXERCISE 1
#   Add a FlacHandler with no edit to PlayerRegistry or any existing class.
# SOLUTION 1:
#   class FlacPlayer
#     include Player
#     def play(track : String) : String; "FLAC: #{track}"; end
#   end
#   class FlacHandler < FormatHandler
#     def create_player : Player; FlacPlayer.new; end
#   end
#   registry.register("flac", FlacHandler.new)
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a fallback "unknown" player with a default_extension option.
# SOLUTION 2:
#   @default : FormatHandler? = nil
#   def default_extension=(handler : FormatHandler?); @default = handler; end
#   def player_for(filename) : Player
#     @handlers[ext]? || @default || raise "unsupported: .#{ext}"
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is the registry approach "more open" than adding another `case`?
# SOLUTION 3:
#   New formats are registered from the outside; the registry code path is
#   a single hash lookup and never changes. This is textbook OCP: extension
#   by adding entries (data), not by editing code.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
