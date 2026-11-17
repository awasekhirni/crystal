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
#   Unix pipes: `cat file | gzip | base64`. Each tool wraps a stream, doing
#   one transformation. The next tool reads the previous tool's output the
#   same way it would read a file. Stream decorators build pipelines the
#   same way.
#
# SETUP:
#   crystal run 053_decorator_streams.cr
# =============================================================================

# --- Interface: a simple stream that yields bytes/strings ------------------
module Stream
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  abstract def write(data : String) : Nil
  # Return the full contents as a single String.
  abstract def read_all : String
end

# Concrete class `MemoryStream`.
class MemoryStream
  include Stream
  @buffer = IO::Memory.new
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(data : String) : Nil; @buffer << data; end
  # Return the full contents as a single String.
  def read_all : String; @buffer.to_s; end
end

# --- Abstract decorator ----------------------------------------------------
abstract class StreamDecorator
  include Stream
  def initialize(@inner : Stream); end
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(data : String) : Nil; @inner.write(data); end
  # Return the full contents as a single String.
  def read_all : String; @inner.read_all; end
end

# --- Concrete decorators ---------------------------------------------------
class ReverseStream < StreamDecorator
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(data : String); super(data.reverse); end
  # Return the full contents as a single String.
  def read_all; super.reverse; end
end

# Concrete class `UppercaseStream` -- extends StreamDecorator.
class UppercaseStream < StreamDecorator
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(data : String); super(data.upcase); end
end

# Concrete class `Base64Stream` -- extends StreamDecorator.
class Base64Stream < StreamDecorator
  # Crystal stdlib doesn't ship base64 in every version; keep it illustrative.
  def write(data : String)
    encoded = data.bytes.map { |b| b.to_s(16) }.join
    super(encoded)
  end
end

# ---- Demonstration ----------------------------------------------------------
raw = MemoryStream.new
pipe = UppercaseStream.new(ReverseStream.new(raw))
pipe.write("hello")
puts raw.read_all          # OLLEH (reversed then uppercased before storing)
puts pipe.read_all         # HELLO (reverse again on read)

# =============================================================================
# EXERCISE 1
#   Add a CountingStream decorator that tracks bytes written.
# SOLUTION 1:
#   class CountingStream < StreamDecorator
#     property bytes = 0
#     def write(data); @bytes += data.bytesize; super; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Write a stream that prepends a length header to every write.
# SOLUTION 2:
#   class LengthPrefixedStream < StreamDecorator
#     def write(data); super("#{data.bytesize}:#{data}"); end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare with real IO wrapping in Crystal's stdlib.
# SOLUTION 3:
#   Crystal's stdlib uses the same shape: IO::Memory, IO::Buffered, etc.
#   Wrapping works because all conform to IO. Our toy Stream mirrors that
#   idea — a common abstraction (write/read) plus composable wrappers.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
