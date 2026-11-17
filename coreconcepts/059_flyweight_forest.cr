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
#   A forest has thousands of trees but only a few species. Each species
#   shares its sprite and color; each instance only carries position and
#   (optionally) size. Flyweight = shared species object + tiny per-instance
#   record.
#
# SETUP:
#   crystal run 059_flyweight_forest.cr
# =============================================================================

# Intrinsic: species definition (heavy, shared).
class TreeType
  getter name : String, color : String, texture : String
  def initialize(@name : String, @color : String, @texture : String); end
  # Return a short String describing the drawn shape/node.
  def draw(x : Int32, y : Int32) : String
    "#{@name}(#{@color}) at (#{x},#{y}) [tex=#{@texture}]"
  end
end

# Concrete class `TreeTypeFactory`.
class TreeTypeFactory
  @types = {} of String => TreeType
  # Look up `key`; returns the value or Nil if absent.
  def get(name : String, color : String, texture : String) : TreeType
    @types[name] ||= TreeType.new(name, color, texture)
  end
end

# Extrinsic: per-tree data (light).
struct Tree
  getter type : TreeType, x : Int32, y : Int32
  def initialize(@type : TreeType, @x : Int32, @y : Int32); end
  # Return a short String describing the drawn shape/node.
  def draw : String; @type.draw(@x, @y); end
end

# Concrete class `Forest`.
class Forest
  def initialize(@factory : TreeTypeFactory); end
  @trees = [] of Tree

  # Return the result of `plant`.
  def plant(name : String, color : String, texture : String, x : Int32, y : Int32) : Nil
    @trees << Tree.new(@factory.get(name, color, texture), x, y)
  end

  # Return the result of `draw_all`.
  def draw_all(limit : Int32 = 5) : Nil
    @trees.first(limit).each { |t| puts t.draw }
  end
end

# ---- Demonstration ----------------------------------------------------------
factory = TreeTypeFactory.new
forest = Forest.new(factory)
10.times { |i| forest.plant("Pine", "green", "pine.png", i * 2, i * 3) }
10.times { |i| forest.plant("Oak",  "brown", "oak.png", i * 3, i * 2) }
forest.draw_all(4)
puts "Distinct tree types: 2 (shared across 20 trees)"

# =============================================================================
# EXERCISE 1
#   Add a "size" attribute per tree that scales the draw call.
# SOLUTION 1:
#   Tree gains a `size : Float64` field (extrinsic). draw calls
#   @type.draw_scaled(@x, @y, @size). TreeType gets a `draw_scaled` method
#   that multiplies texture coordinates — but keeps shape intrinsic.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Compare memory: naive 20 trees × full TreeType vs flyweight.
# SOLUTION 2:
#   Naive: 20 × (3 strings + metadata) ≈ 20 heavy objects. Flyweight: 2
#   TreeTypes + 20 small Tree structs (2 ints + 1 pointer). The ratio grows
#   with instance count; flyweight pays off when duplicates dominate.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   What concurrency issue could exist in TreeTypeFactory#get?
# SOLUTION 3:
#   Two threads could both miss the cache and create duplicate TreeType
#   instances, breaking the "shared" invariant. Fix with a Mutex around get,
#   or pre-populate all species at startup (immutable thereafter). Prefer
#   the second: flyweight caches are perfect for "warm up once, read many".
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
