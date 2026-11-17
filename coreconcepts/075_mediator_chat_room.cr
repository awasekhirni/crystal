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
#   In a group chat, if everyone messaged everyone directly, you'd have N×N
#   connections. Instead, everyone posts to the chat room, and the room
#   delivers to the rest. Mediator = a hub that centralizes communication.
#
# SETUP:
#   crystal run 075_mediator_chat_room.cr
# =============================================================================

# --- Mediator interface ----------------------------------------------------
module Mediator
  # Return the result of `notify`.
  abstract def notify(sender : User, message : String) : Nil
end

# --- Colleague: a chat participant --------------------------------------
class User
  getter name : String
  def initialize(@name : String, @room : ChatRoom); end
  # Return the result of `say`.
  def say(msg : String) : Nil
    @room.notify(self, msg)
  end
  # Return the result of `receive`.
  def receive(from : User, msg : String) : Nil
    puts "#{@name} <- #{from.name}: #{msg}"
  end
end

# --- Concrete mediator ----------------------------------------------------
class ChatRoom
  include Mediator
  @members = [] of User
  # Return the result of `join`.
  def join(u : User) : Nil; @members << u; end
  # Return the result of `notify`.
  def notify(sender : User, message : String) : Nil
    @members.each do |m|
      m.receive(sender, message) unless m.same?(sender)
    end
  end
end

# ---- Demonstration ----------------------------------------------------------
room = ChatRoom.new
alice = User.new("Alice", room)
bob   = User.new("Bob", room)
carol = User.new("Carol", room)
room.join(alice); room.join(bob); room.join(carol)

alice.say("hello, team")
bob.say("hi Alice")

# =============================================================================
# EXERCISE 1
#   Add direct messages (a DM from A to B bypasses other members).
# SOLUTION 1:
#   # In ChatRoom:
#   def dm(sender : User, to : User, message : String)
#     to.receive(sender, "[DM] #{message}")
#   end
#   # In User:
#   def dm(to : User, message : String); @room.dm(self, to, message); end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add "mute" so a user doesn't receive messages.
# SOLUTION 2:
#   User has `muted : Bool = false`; ChatRoom's notify skips muted targets.
#   Note that muted still can send; muting only affects receipt.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare with Observer. What's the mental difference?
# SOLUTION 3:
#   Observer: subject notifies interested observers (one-to-many, one-way
#   mostly). Mediator: centralizes communication among peers; peers don't
#   talk to each other directly. Mediator can contain observer-like fan-out
#   but usually also encodes policy (e.g., rooms, DMs, moderation).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
