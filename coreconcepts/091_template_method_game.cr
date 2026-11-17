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
#   Every game has a loop: setup, per-turn play, check winner, cleanup. The
#   loop is the same; the specific game logic differs. Template Method =
#   common skeleton, per-game rules filled in by subclasses.
#
# SETUP:
#   crystal run 091_template_method_game.cr
# =============================================================================

# Abstract class `Game`.
abstract class Game
  # Final skeleton of a match. Subclasses implement hooks only.
  def play : Nil
    setup
    until finished?
      take_turn
    end
    announce_winner
    cleanup
  end

  # Return the result of `setup`.
  abstract def setup : Nil
  # Return the result of `take_turn`.
  abstract def take_turn : Nil
  # Return true if `finished` holds.
  abstract def finished? : Bool
  # Return the result of `announce_winner`.
  abstract def announce_winner : Nil

  # Optional hook: default no-op cleanup.
  def cleanup : Nil; end
end

# --- Rock-Paper-Scissors (deterministic demo) ---------------------------
class RPSGame < Game
  @round = 0

  # Return the result of `setup`.
  def setup : Nil
    puts "Best of 3 RPS"
    @round = 0
  end

  # Return true if `finished` holds.
  def finished? : Bool
    @round >= 3
  end

  # Return the result of `take_turn`.
  def take_turn : Nil
    @round += 1
    # deterministic pseudo-result for demo
    winner = ["player", "cpu"][@round % 2]
    puts "round #{@round}: #{winner} wins"
  end

  # Return the result of `announce_winner`.
  def announce_winner : Nil
    puts "Game over after #{@round} rounds"
  end
end

# --- Number guessing (also deterministic demo) --------------------------
class GuessGame < Game
  @attempts = 0

  # Return the result of `setup`.
  def setup : Nil
    puts "Guess the number (1..5)"
    @attempts = 0
  end

  # Return true if `finished` holds.
  def finished? : Bool
    @attempts >= 2   # toy stop condition
  end

  # Return the result of `take_turn`.
  def take_turn : Nil
    @attempts += 1
    puts "attempt #{@attempts}: guessing 3..."
  end

  # Return the result of `announce_winner`.
  def announce_winner : Nil
    puts "Guessed in #{@attempts} attempts"
  end

  # Return the result of `cleanup`.
  def cleanup : Nil
    puts "(cleanup: score saved)"
  end
end

# ---- Demonstration ----------------------------------------------------------
RPSGame.new.play
puts
GuessGame.new.play

# =============================================================================
# EXERCISE 1
#   Add a hook `before_turn : Nil` that prints "your turn" for GuessGame only.
# SOLUTION 1:
#   def before_turn : Nil; end
#   # In play loop: before_turn; take_turn
#   # GuessGame overrides before_turn to puts "your turn"
# =============================================================================

# =============================================================================
# EXERCISE 2
#   What's the risk if a subclass overrides `play` instead of the hooks?
# SOLUTION 2:
#   It can break the shared algorithm (skip cleanup, reorder steps, forget
#   terminate condition). Template Method's contract is "override hooks,
#   not the skeleton"; Crystal has no `final` keyword to enforce this, so
#   document it, and prefer making subclasses need to override only hooks.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare with a single `Game#play` using `if`s for each game.
# SOLUTION 3:
#   A single `if @kind == :rps ... elsif @kind == :guess ...` grows with each
#   new game and mixes rules across unrelated games. Template Method forces
#   each new game into its own class implementing the four hooks; skeleton
#   changes happen in one place (Game) and benefit every game uniformly.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
