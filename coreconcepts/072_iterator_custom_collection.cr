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
#   A bookshelf is a collection; a bookmark is a way to visit each book. An
#   iterator separates "what to visit" (the collection) from "how we move
#   through it" (the bookmark). Iterator = an object that yields elements
#   one at a time.
#
# SETUP:
#   crystal run 072_iterator_custom_collection.cr
# =============================================================================

# --- Collection ------------------------------------------------------------
class BookShelf
  def initialize(@books = [] of String); end
  # Add an element and return self for chaining.
  def add(title : String) : BookShelf; @books << title; self; end

  # Iterator as an object.
  def iterator : BookIterator
    BookIterator.new(@books)
  end
end

# --- Iterator --------------------------------------------------------------
class BookIterator
  include Iterator(String)

  def initialize(@books : Array(String), @index : Int32 = 0); end

  # Return the result of `next`.
  def next : Iterator::Stop | String
    return stop if @index >= @books.size
    book = @books[@index]
    @index += 1
    book
  end
end

# ---- Demonstration ----------------------------------------------------------
shelf = BookShelf.new
  .add("The Crystal Book")
  .add("Patterns in Practice")
  .add("SOLID Illustrated")

# Crystal's Iterator module gives us map, select, to_a, each etc. for free.
shelf.iterator.each { |title| puts title }
puts shelf.iterator.to_a.size

# =============================================================================
# EXERCISE 1
#   Add a reverse iterator.
# SOLUTION 1:
#   class ReverseBookIterator
#     include Iterator(String)
#     def initialize(@books, @index = @books.size - 1); end
#     def next
#       return stop if @index < 0
#       book = @books[@index]; @index -= 1; book
#     end
#   end
#   # BookShelf#reverse_iterator returns new ReverseBookIterator(@books)
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add filtering: only books containing "Crystal".
# SOLUTION 2:
#   shelf.iterator.select { |t| t.includes?("Crystal") }.each { |t| puts t }
#   # Iterator module provides select as a lazy adapter; no new class needed.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is Iterator a good alternative to exposing the internal array?
# SOLUTION 3:
#   Exposing @books allows callers to reorder or mutate it, breaking the
#   collection's invariants. Iterators return elements without exposing the
#   underlying storage; you can change the internal structure (linked list,
#   ring buffer) later and the caller's iteration doesn't break.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
