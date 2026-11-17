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
#   A sorting app might use different sort algorithms depending on data
#   size or stability requirements. Strategy = put each algorithm behind a
#   common interface and let the client pick or swap at runtime.
#
# SETUP:
#   crystal run 087_strategy_sorting.cr
# =============================================================================

# --- Strategy interface ----------------------------------------------------
module SortStrategy
  # Return the result of `sort`.
  abstract def sort(data : Array(Int32)) : Array(Int32)
  # Return the human-readable name of this state/object.
  abstract def name : String
end

# --- Concrete strategies --------------------------------------------------
class QuickSort
  include SortStrategy
  # Return the human-readable name of this state/object.
  def name : String; "quick"; end
  # Return the result of `sort`.
  def sort(data : Array(Int32)) : Array(Int32)
    # Simple recursive quick sort (illustrative).
    return data if data.size <= 1
    pivot = data[data.size // 2]
    left = data.select { |x| x < pivot }
    mid  = data.select { |x| x == pivot }
    right = data.select { |x| x > pivot }
    sort(left) + mid + sort(right)
  end
end

# Concrete class `MergeSort`.
class MergeSort
  include SortStrategy
  # Return the human-readable name of this state/object.
  def name : String; "merge"; end
  # Return the result of `sort`.
  def sort(data : Array(Int32)) : Array(Int32)
    return data if data.size <= 1
    mid = data.size // 2
    left = sort(data[0, mid])
    right = sort(data[mid..])
    # merge
    result = [] of Int32
    i = j = 0
    while i < left.size && j < right.size
      if left[i] <= right[j]
        result << left[i]; i += 1
      else
        result << right[j]; j += 1
      end
    end
    result.concat(left[i..]).concat(right[j..])
  end
end

# Concrete class `BuiltinSort`.
class BuiltinSort
  include SortStrategy
  # Return the human-readable name of this state/object.
  def name : String; "builtin"; end
  # Return the result of `sort`.
  def sort(data : Array(Int32)) : Array(Int32); data.sort; end
end

# --- Context --------------------------------------------------------------
class Sorter
  def initialize(@strategy : SortStrategy); end
  # Return the result of `strategy=`.
  def strategy=(@strategy : SortStrategy); end
  # Return the result of `sort`.
  def sort(data : Array(Int32)) : Array(Int32); @strategy.sort(data); end
  # Return the human-readable name of this state/object.
  def name : String; @strategy.name; end
end

# ---- Demonstration ----------------------------------------------------------
data = [5, 3, 8, 1, 9, 2]
[QuickSort.new, MergeSort.new, BuiltinSort.new].each do |s|
  sorter = Sorter.new(s)
  puts "#{sorter.name}: #{sorter.sort(data.dup)}"
end

# =============================================================================
# EXERCISE 1
#   Add a BubbleSort strategy.
# SOLUTION 1:
#   class BubbleSort
#     include SortStrategy
#     def name; "bubble"; end
#     def sort(d)
#       a = d.dup
#       (a.size - 1).times do |i|
#         (a.size - 1 - i).times do |j|
#           a[j], a[j + 1] = a[j + 1], a[j] if a[j] > a[j + 1]
#         end
#       end
#       a
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Auto-pick strategy by size (small → builtin, huge → merge).
# SOLUTION 2:
#   def self.for(data)
#     data.size > 10_000 ? MergeSort.new : BuiltinSort.new
#   end
#   # Choose at context init based on data — the choice itself is a Strategy.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare Strategy with State: both swap an object behind an interface.
# SOLUTION 3:
#   Strategy is chosen externally by the client and doesn't change itself.
#   State is managed internally by the context: state transitions are part
#   of the pattern. Strategys are interchangeable algorithms; States model
#   protocol/lifecycle. You might use a Strategy inside a State to pick an
#   algorithm for that state.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
