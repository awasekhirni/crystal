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
#   A newspaper page has 5000 characters, but only ~60 distinct glyphs
#   (a–z, A–Z, digits, punctuation). We don't need 5000 separate glyph
#   drawings; we share each glyph's "shape" and record just the position.
#   Flyweight = share the heavy, immutable part; keep the small, varying
#   part outside.
#
# SETUP:
#   crystal run 058_flyweight_characters.cr
# =============================================================================

# Intrinsic state (shared, immutable): the glyph shape.
class Glyph
  getter char : Char, font : String
  def initialize(@char : Char, @font : String); end
  # Return a short String describing the drawn shape/node.
  def draw(x : Int32, y : Int32) : String
    "draw('#{@char}' #{@font}) at (#{x},#{y})"
  end
end

# Flyweight factory: ensures we reuse glyphs per (char, font) pair.
class GlyphFactory
  @cache = {} of Tuple(Char, String) => Glyph
  # Look up `key`; returns the value or Nil if absent.
  def get(char : Char, font : String = "Arial") : Glyph
    key = {char, font}
    @cache[key] ||= Glyph.new(char, font)
  end
  # Return the result of `size`.
  def size : Int32; @cache.size; end
end

# Extrinsic state: position is passed at draw time, not stored in the glyph.
class Document
  def initialize(@factory : GlyphFactory); end
  @positions = [] of {Glyph, Int32, Int32}

  # Return the result of `type_char`.
  def type_char(c : Char, x : Int32, y : Int32) : Nil
    @positions << {@factory.get(c), x, y}
  end

  # Render the receiver to a String representation.
  def render : Nil
    @positions.each { |(glyph, x, y)| puts glyph.draw(x, y) }
  end
end

# ---- Demonstration ----------------------------------------------------------
factory = GlyphFactory.new
doc = Document.new(factory)
"hello hello".each_char_with_index do |c, i|
  doc.type_char(c, i * 10, 0)
end
doc.render
puts "Distinct glyphs cached: #{factory.size}"   # h, e, l, o, space => 5

# =============================================================================
# EXERCISE 1
#   Add fonts: extend the cache key to (char, font) and type some text in
#   bold and italic — show cache growth.
# SOLUTION 1:
#   doc.type_char('H', 0, 0) already uses default font; add a helper:
#   def type_styled(c : Char, x : Int32, y : Int32, font : String)
#     @positions << {@factory.get(c, font), x, y}
#   end
#   # Cache now contains entries for each (char, font) combination used.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Explain why storing (x, y) inside Glyph would defeat the pattern.
# SOLUTION 2:
#   Position varies per occurrence, so caching per position makes almost no
#   hits (each position is typically unique). You'd have n distinct objects,
#   not k. Flyweight works only when intrinsic state is reused widely.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a "bold" style as a boolean attribute — how does it affect the key?
# SOLUTION 3:
#   If bold is per-character and used in the key, cache size multiplies by 2
#   (bold/regular). If bold is applied at draw-time as a post-processing
#   concern, keep it out of the key and pass it to draw — but then Glyph
#   itself remains immutable, which is important for sharing.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
