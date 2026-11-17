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
#   In a drawing app, every "add line" or "erase" can be undone. Each action
#   needs to know how to undo itself. Command = an object with both do and
#   undo. A history of commands lets you undo in reverse order.
#
# SETUP:
#   crystal run 070_command_undo.cr
# =============================================================================

# Concrete class `TextBuffer`.
class TextBuffer
  getter content : String = ""
  # Return the result of `append`.
  def append(s : String) : Nil; @content += s; end
  # Return the result of `delete`.
  def delete(n : Int32) : Nil; @content = @content[0, @content.size - n] if n <= @content.size; end
  # Return the result of `replace`.
  def replace(s : String) : Nil; @content = s; end
end

# --- Command abstraction with undo ----------------------------------------
abstract class Command
  # Return the result of `execute`.
  abstract def execute : Nil
  # Return the result of `undo`.
  abstract def undo : Nil
end

# Concrete class `AppendText` -- extends Command.
class AppendText < Command
  def initialize(@buffer : TextBuffer, @text : String); end
  # Return the result of `execute`.
  def execute : Nil; @buffer.append(@text); end
  # Return the result of `undo`.
  def undo : Nil; @buffer.delete(@text.size); end
end

# Concrete class `ReplaceText` -- extends Command.
class ReplaceText < Command
  def initialize(@buffer : TextBuffer, @new_text : String); end
  @previous : String = ""

  # Return the result of `execute`.
  def execute : Nil
    @previous = @buffer.content
    @buffer.replace(@new_text)
  end

  # Return the result of `undo`.
  def undo : Nil
    @buffer.replace(@previous)
  end
end

# --- Invoker with undo/redo stacks ----------------------------------------
class Editor
  def initialize(@buffer : TextBuffer = TextBuffer.new); end
  @undo_stack = [] of Command
  @redo_stack = [] of Command

  # Execute the template-method pipeline and return the result.
  def run(cmd : Command) : Nil
    cmd.execute
    @undo_stack << cmd
    @redo_stack.clear
  end

  # Return the result of `undo`.
  def undo : Nil
    if cmd = @undo_stack.pop?
      cmd.undo
      @redo_stack << cmd
    end
  end

  # Return the result of `redo`.
  def redo : Nil
    if cmd = @redo_stack.pop?
      cmd.execute
      @undo_stack << cmd
    end
  end

  # Return the result of `content`.
  def content : String; @buffer.content; end
end

# ---- Demonstration ----------------------------------------------------------
editor = Editor.new
editor.run(AppendText.new(TextBuffer.new, "hello"))
# Note: the above creates a new TextBuffer for the command! Demonstrate
# correct usage instead:
editor = Editor.new
buf = TextBuffer.new
# We need editor to share the buffer; give Editor an accessor instead.

# (Simplify: run commands against a shared buffer through the editor's buffer.)
class Editor
  # Return the result of `buffer`.
  def buffer : TextBuffer
    # expose the buffer used by commands (real code would inject)
    @buffer
  end
end

buf = editor.buffer
editor.run(AppendText.new(buf, "hello "))
editor.run(AppendText.new(buf, "world"))
puts editor.content           # "hello world"
editor.undo
puts editor.content           # "hello "
editor.undo
puts editor.content           # ""
editor.redo
puts editor.content           # "hello "
editor.redo
puts editor.content           # "hello world"

# =============================================================================
# EXERCISE 1
#   Add a "delete last word" command with proper undo (restores the word).
# SOLUTION 1:
#   class DeleteLastWord < Command
#     def initialize(@buf : TextBuffer); end
#     @deleted = ""
#     def execute
#       @deleted = @buf.content.split(" ").last? || ""
#       @buf.delete(@deleted.size)
#     end
#     def undo; @buf.append(@deleted); end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a MacroCommand with undo — undoing must undo the children in reverse.
# SOLUTION 2:
#   class MacroCommand < Command
#     def initialize(@cmds : Array(Command)); end
#     def execute; @cmds.each(&.execute); end
#     def undo; @cmds.reverse_each(&.undo); end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Discuss memory growth: undo stacks grow forever. How to cap?
# SOLUTION 3:
#   Keep a max depth (e.g., 100) and drop from the front. Alternatively
#   persist commands to disk for very long sessions, or coalesce consecutive
#   small edits (typing bursts) into a single command.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
