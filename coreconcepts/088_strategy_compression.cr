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
#   When saving files, sometimes you want speed (fast, big files), sometimes
#   size (slow, small). Strategy = swap the compressor on demand.
#
# SETUP:
#   crystal run 088_strategy_compression.cr
# =============================================================================

# Module `Compression`.
module Compression
  # Return the result of `compress`.
  abstract def compress(data : String) : String
  # Return the result of `decompress`.
  abstract def decompress(data : String) : String
  # Return the human-readable name of this state/object.
  abstract def name : String
end

# Toy "strategies" that visibly differ (real ones would use zlib/gzip).
class NoCompression
  include Compression
  # Return the human-readable name of this state/object.
  def name : String; "none"; end
  # Return the result of `compress`.
  def compress(data : String) : String; data; end
  # Return the result of `decompress`.
  def decompress(data : String) : String; data; end
end

# Concrete class `RunLengthEncoding`.
class RunLengthEncoding
  include Compression
  # Return the human-readable name of this state/object.
  def name : String; "rle"; end
  # Return the result of `compress`.
  def compress(data : String) : String
    # "aaaabbb" -> "a4b3"
    result = String.build do |io|
      i = 0
      while i < data.size
        ch = data[i]
        count = 1
        while i + count < data.size && data[i + count] == ch
          count += 1
        end
        io << ch << count
        i += count
      end
    end
    result
  end
  # Return the result of `decompress`.
  def decompress(data : String) : String
    # Parse "a4b3"
    String.build do |io|
      i = 0
      while i < data.size
        ch = data[i]
        num_start = i + 1
        j = num_start
        while j < data.size && data[j].ascii_number?
          j += 1
        end
        count = data[num_start, j - num_start].to_i
        count.times { io << ch }
        i = j
      end
    end
  end
end

# --- Context --------------------------------------------------------------
class FileWriter
  def initialize(@compression : Compression); end
  # Return the result of `compression=`.
  def compression=(@compression : Compression); end
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(path : String, content : String) : Nil
    encoded = @compression.compress(content)
    File.write(path, encoded)
    puts "wrote #{content.bytesize}B as #{encoded.bytesize}B using #{@compression.name}"
  end
  # Read and return the source as a String.
  def read(path : String) : String
    @compression.decompress(File.read(path))
  end
end

# ---- Demonstration ----------------------------------------------------------
content = "aaaaaaaaaabbbbbbbbbbcccccccc"
FileWriter.new(NoCompression.new).write("/tmp/s88_raw", content)
FileWriter.new(RunLengthEncoding.new).write("/tmp/s88_rle", content)
puts FileWriter.new(RunLengthEncoding.new).read("/tmp/s88_rle")

# =============================================================================
# EXERCISE 1
#   Add a "reverse" compression for demonstration and show byte counts.
# SOLUTION 1:
#   class ReverseCompression
#     include Compression
#     def name; "reverse"; end
#     def compress(d); d.reverse; end
#     def decompress(d); d.reverse; end
#   end
#   # Same byte count but "compressed" — illustrates that strategy correctness
#   # matters more than just swapping bytes.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Support chunked decompress for very large files.
# SOLUTION 2:
#   def decompress_io(io : IO, &block : String -> Nil)
#     # Read chunks of encoded input, decode incrementally, yield each chunk.
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is Strategy better than an enum here?
# SOLUTION 3:
#   A `case :none | :rle | :gzip` centralizes every strategy in one method
#   (OCP violation), makes testing each branch harder, and prevents
#   parameterization per-strategy (e.g., compression level). Strategy
#   encapsulates each algorithm, its data, and its configuration behind one
#   interface — extensible without editing the context.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
