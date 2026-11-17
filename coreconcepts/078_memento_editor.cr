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
#   A video game has a "save" button. Before a boss fight, you save; if you
#   die, you reload. Memento = a snapshot of an object's state that the
#   object itself can restore from, without exposing its internals.
#
# SETUP:
#   crystal run 078_memento_editor.cr
# =============================================================================

# --- Memento: opaque snapshot ---------------------------------------------
# The Memento stores state but exposes nothing mutable. Only the originator
# (TextEditor) knows how to interpret it.
class EditorMemento
  # Private-ish: no public getters.
  getter state : String
  def initialize(@state : String); end
end

# --- Originator: TextEditor ----------------------------------------------
class TextEditor
  property content : String = ""
  property cursor : Int32 = 0

  # Return the result of `type`.
  def type(text : String) : Nil
    @content += text
    @cursor = @content.size
  end

  # Persist the rows.  Returns Nil.
  def save : EditorMemento
    EditorMemento.new("#{@cursor}|#{@content}")
  end

  # Return the result of `restore`.
  def restore(m : EditorMemento) : Nil
    parts = m.state.split("|", 2)
    @cursor = parts[0].to_i
    @content = parts[1]? || ""
  end
end

# --- Caretaker: keeps a stack of mementos --------------------------------
class History
  @snapshots = [] of EditorMemento
  # Return the result of `push`.
  def push(m : EditorMemento) : Nil; @snapshots << m; end
  # Return the result of `pop`.
  def pop : EditorMemento?; @snapshots.pop?; end
end

# ---- Demonstration ----------------------------------------------------------
editor = TextEditor.new
history = History.new

editor.type("Hello")
history.push(editor.save)
editor.type(", world")
history.push(editor.save)
editor.type("!")

puts "current: #{editor.content}"     # Hello, world!

if m = history.pop
  editor.restore(m)
  puts "undo1:  #{editor.content}"    # Hello, world
end

if m = history.pop
  editor.restore(m)
  puts "undo2:  #{editor.content}"    # Hello
end

# =============================================================================
# EXERCISE 1
#   Add "selection" state to the editor and include it in the memento.
# SOLUTION 1:
#   property selection : String = ""
#   save: EditorMemento.new("#{@cursor}|#{@selection}|#{@content}")
#   restore: split into 3 parts.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Limit history to 20 entries (drop oldest).
# SOLUTION 2:
#   def push(m); @snapshots << m; @snapshots.shift if @snapshots.size > 20; end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why does Memento have "no public getters"?
# SOLUTION 3:
#   Encapsulation: only the originator should be able to write state back.
#   If caretakers or clients could read/write individual fields, they'd be
#   coupled to the originator's internals and could produce corrupt states.
#   Opaque mementos keep all know-how inside the originator, satisfying SRP.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
