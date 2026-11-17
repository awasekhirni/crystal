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
#   A USB-C ↔ 3.5mm audio dongle is "two-way": you can plug headphones into
#   a phone, and (with the right dongle) a mic into a speaker. A two-way
#   adapter lets either side treat the other through its native interface.
#
# SETUP:
#   crystal run 044_adapter_two_way.cr
# =============================================================================

# --- Two different "shapes" of code: a modern streaming interface and a
# --- legacy chunk-based copier.  A `ChunkReader` module lets both the
# --- legacy class and the two-way adapter be passed to `consume_legacy`.
module Streamer
  # Return the data as a chunked Array(String).
  abstract def stream(chunk_size : Int32) : Array(String)
end

# Module `ChunkReader`.
module ChunkReader
  # Return the legacy chunk list.
  abstract def read_chunks : Array(String)
end

# Concrete class `LegacyChunkReader`.
class LegacyChunkReader
  include ChunkReader
  # Return the legacy chunk list.
  def read_chunks : Array(String)
    ["aa", "bb", "cc", "dd"]
  end
end

# --- Two-way adapter: it IS a Streamer AND a ChunkReader -----------------
class TwoWayAdapter
  include Streamer
  include ChunkReader

  def initialize(@legacy : LegacyChunkReader); end

  # Streamer side: read as chunks.
  # `.each_slice(chunk_size).map(&.join)` returns an Iterator; the declared
  # return type is `Array(String)`, so we call `.to_a` to materialize it.
  def stream(chunk_size : Int32) : Array(String)
    @legacy.read_chunks.each_slice(chunk_size).map(&.join).to_a
  end

  # Legacy side: let a Streamer be consumed by code expecting a chunk reader.
  def read_chunks : Array(String)
    # Just delegate to legacy here (adapter does not have its own data).
    @legacy.read_chunks
  end
end

# --- Client 1: expects Streamer --------------------------------------------
def consume_stream(s : Streamer) : Nil
  puts s.stream(2)
end

# --- Client 2: expects an object with read_chunks --------------------------
# Accepts the `ChunkReader` module so any compatible object (the legacy
# reader OR the two-way adapter) can be passed in -- true two-way use.
def consume_legacy(reader : ChunkReader) : Nil
  puts reader.read_chunks.size
end

# ---- Demonstration ----------------------------------------------------------
adapter = TwoWayAdapter.new(LegacyChunkReader.new)
consume_stream(adapter)
consume_legacy(adapter)

# =============================================================================
# EXERCISE 1
#   Extend TwoWayAdapter so `read_chunks` can also be called on a Streamer.
# SOLUTION 1:
#   Overload `self.from_stream(s : Streamer) : LegacyChunkReader`.
#   But `LegacyChunkReader` isn't our type; instead define a compatible
#   class LegacyChunkReaderFromStream with the same method signature.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   When is two-way adapter overkill?
# SOLUTION 2:
#   When only one side actually needs adapting. Keeping two responsibilities
#   in one class breaks SRP and complicates testing. Prefer two one-way
#   adapters when the second direction is rarely used.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Draw the class relationships in text and explain them.
# SOLUTION 3:
#   LegacyChunkReader <---(composed by)--- TwoWayAdapter ---(includes)---> Streamer
#   The adapter contains the legacy reader and implements the modern
#   interface, so callers on either side can treat the adapter as "the other
#   thing they already understand".
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
