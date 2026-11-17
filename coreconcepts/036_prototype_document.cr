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
#   Have you ever "Save a copy" of a document and then edit only one? That's
#   cloning a prototype. Instead of building a new document from scratch
#   (expensive), copy an existing one and tweak it.
#
# SETUP:
#   crystal run 036_prototype_document.cr
# =============================================================================

# Abstract class `Document`.
abstract class Document
  # Return the result of `clone_doc`.
  abstract def clone_doc : Document
  # Return the result of `describe`.
  abstract def describe : String
end

# Concrete class `TextDoc` -- extends Document.
class TextDoc < Document
  getter content : String
  def initialize(@content : String); end
  # Prototype contract: return a new instance with copied state.
  def clone_doc : Document; TextDoc.new(@content.dup); end
  # Return the result of `describe`.
  def describe : String; "TextDoc(#{@content})"; end
end

# Concrete class `SheetDoc` -- extends Document.
class SheetDoc < Document
  getter cells : Hash(String, String)
  def initialize(@cells : Hash(String, String)); end
  # Return the result of `clone_doc`.
  def clone_doc : Document; SheetDoc.new(@cells.dup); end
  # Return the result of `describe`.
  def describe : String; "SheetDoc(#{@cells.size} cells)"; end
end

# ---- Demonstration ----------------------------------------------------------
original = SheetDoc.new({"A1" => "10", "A2" => "20"})
copy = original.clone_doc.as(SheetDoc)
copy.cells["A3"] = "30"
puts original.describe   # 2 cells (unchanged)
puts copy.describe       # 3 cells (independent)

# =============================================================================
# EXERCISE 1
#   Add a NoteDoc with a list of tags. Implement clone_doc safely.
# SOLUTION 1:
#   class NoteDoc < Document
#     getter tags : Array(String)
#     def initialize(@tags : Array(String)); end
#     def clone_doc : Document; NoteDoc.new(@tags.dup); end
#     def describe : String; "NoteDoc(#{@tags.join(",")})"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `deep_clone` for SheetDoc with nested Hash(String, Hash(String,String)).
# SOLUTION 2:
#   def clone_doc : Document
#     nested = @cells.transform_values(&.dup)
#     SheetDoc.new(nested)
#   end
#   # For deeply nested structures, recursively dup or Marshal round-trip.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why might Crystal's `#dup` or `#clone` on your own class be insufficient?
# SOLUTION 3:
#   Crystal's `dup`/`clone` do shallow copying by default. Fields that are
#   arrays/hashes will still share storage after clone. Prototype's contract
#   is semantic: the copy must be safe to mutate independently. Therefore
#   we override with explicit deep copies where needed.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
