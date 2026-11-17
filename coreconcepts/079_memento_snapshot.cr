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
#   When you edit a form, the app can offer "Revert changes" after you save.
#   A snapshot of the form (as data) is stored. Clicking revert restores it.
#
# SETUP:
#   crystal run 079_memento_snapshot.cr
# =============================================================================

# --- Memento with value snapshots ----------------------------------------
class FormMemento
  # Immutable tuple of field -> value.
  getter snapshot : Hash(String, String)
  def initialize(@snapshot : Hash(String, String)); end
end

# --- Originator: a form with fields --------------------------------------
class Form
  def initialize(@fields : Hash(String, String)); end
  # Return the result of `set`.
  def set(key : String, val : String) : Nil
    raise "unknown field #{key}" unless @fields.has_key?(key)
    @fields[key] = val
  end
  # Look up `key`; returns the value or Nil if absent.
  def get(key : String) : String?; @fields[key]?; end

  # Return the result of `snapshot`.
  def snapshot : FormMemento
    FormMemento.new(@fields.dup)
  end

  # Return the result of `restore`.
  def restore(m : FormMemento) : Nil
    @fields = m.snapshot.dup
  end

  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil
    @fields.each { |k, v| io << "#{k}=#{v} " }
  end
end

# --- Caretaker: named snapshots ------------------------------------------
class FormHistory
  @snaps = Hash(String, FormMemento).new
  # Return the result of `save_as`.
  def save_as(name : String, m : FormMemento) : Nil; @snaps[name] = m; end
  # Return the result of `load`.
  def load(name : String) : FormMemento?
    @snaps[name]?
  end
end

# ---- Demonstration ----------------------------------------------------------
form = Form.new({"name" => "", "email" => ""})
history = FormHistory.new

form.set("name", "Alice")
form.set("email", "alice@example.com")
history.save_as("initial", form.snapshot)

form.set("name", "Bob")
form.set("email", "bob@example.com")
puts "modified: #{form}"

if m = history.load("initial")
  form.restore(m)
  puts "restored: #{form}"
end

# =============================================================================
# EXERCISE 1
#   Add "compare" that shows which fields changed between two mementos.
# SOLUTION 1:
#   def diff(a : FormMemento, b : FormMemento) : Hash(String, {String?, String?})
#     keys = (a.snapshot.keys + b.snapshot.keys).uniq
#     keys.each_with_object({} of String => {String?, String?}) do |k, h|
#       h[k] = {a.snapshot[k]?, b.snapshot[k]?} if a.snapshot[k]? != b.snapshot[k]?
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Deep-copy a memento so external mutation doesn't affect history.
# SOLUTION 2:
#   FormMemento.new(@fields.transform_values(&.dup))
#   # For nested values, recursively dup. In this simple Hash(String,String)
#   # .dup is enough.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is Memento not just "serialize to JSON"?
# SOLUTION 3:
#   Memento is an OOP design idea: the originator defines the snapshot
#   format and the caretaker treats it opaquely. Serialization is a
#   transport concern; a memento can be in-memory and never leave the
#   process. You could serialize mementos for durable storage, but that's
#   orthogonal. Memento is about encapsulation, not encoding.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
