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
#   Reading the same 10 config files over and over wastes time. A shared
#   "cache" keeps one copy keyed by file name. Everyone shares; nobody
#   mutates. That's flyweight in a non-graphical context.
#
# SETUP:
#   crystal run 060_flyweight_cache.cr
# =============================================================================

# Shared, immutable file content.
class FileContent
  getter path : String, content : String
  def initialize(@path : String, @content : String); end
  # Return the result of `lines`.
  def lines : Int32; @content.count('\n') + 1; end
end

# Flyweight factory with get-or-load semantics.
class FileContentCache
  @cache = {} of String => FileContent
  getter hits = 0, misses = 0

  # Return the result of `load`.
  def load(path : String) : FileContent
    if cached = @cache[path]?
      @hits += 1
      return cached
    end
    @misses += 1
    content = File.exists?(path) ? File.read(path) : "simulated content of #{path}"
    @cache[path] = FileContent.new(path, content)
  end
end

# ---- Demonstration ----------------------------------------------------------
cache = FileContentCache.new
puts cache.load("/tmp/flyweight_demo.txt").lines
puts cache.load("/tmp/flyweight_demo.txt").lines
puts cache.load("/tmp/flyweight_demo.txt").lines
puts "hits=#{cache.hits} misses=#{cache.misses}"   # 2 hits, 1 miss

# =============================================================================
# EXERCISE 1
#   Add a max_entries limit and evict LRU.
# SOLUTION 1:
#   @order = [] of String
#   def load(path)
#     # existing hit path: move path to end of @order
#     # miss: if @cache.size >= @max; evict = @order.shift; @cache.delete(evict)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add invalidation for a single path (e.g., after write).
# SOLUTION 2:
#   def invalidate(path : String) : Nil
#     @cache.delete(path)
#     @order.delete(path)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is "immutability of FileContent" essential to Flyweight here?
# SOLUTION 3:
#   If one caller could mutate `content`, all other users of the shared
#   object would silently observe the change — a classic shared-state bug.
#   Immutability guarantees the sharing is safe. It also lets us hand out the
#   same instance across threads without locks (for the object itself).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
