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
#   A logger knows how to write logs. The "creator" side decides WHICH kind
#   of underlying writer to use. The creator can also take a "product
#   configuration" so the factory call is parameterized.
#
# SETUP:
#   crystal run 024_factory_method_creators.cr
# =============================================================================

# --- Products ---------------------------------------------------------------
module Writer
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  abstract def write(line : String) : Nil
end

# Concrete class `StdoutWriter`.
class StdoutWriter
  include Writer
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(line : String) : Nil; puts line; end
end

# Concrete class `BufferedWriter`.
class BufferedWriter
  include Writer
  @buffer = [] of String
  getter buffer
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(line : String) : Nil; @buffer << line; end
end

# --- Abstract creator -------------------------------------------------------
abstract class LoggerFactory
  # Parameterized factory method — the config flows into construction.
  abstract def create_writer(config : Hash(String, String)) : Writer

  # Template method using the product.
  def log(level : String, msg : String, config : Hash(String, String) = {} of String => String) : Nil
    create_writer(config).write("[#{level}] #{msg}")
  end
end

# --- Concrete creators ------------------------------------------------------
class ConsoleLoggerFactory < LoggerFactory
  # Return the result of `create_writer`.
  def create_writer(config : Hash(String, String)) : Writer
    StdoutWriter.new
  end
end

# Concrete class `BufferedLoggerFactory` -- extends LoggerFactory.
class BufferedLoggerFactory < LoggerFactory
  # Cache the writer so multiple log calls hit the same buffer. Concrete
  # creator can hold state — this is a key difference vs static factories.
  @writer : BufferedWriter?

  # Return the result of `create_writer`.
  def create_writer(config : Hash(String, String)) : Writer
    @writer ||= BufferedWriter.new
  end

  # Return the result of `buffered_writer`.
  def buffered_writer : BufferedWriter
    @writer ||= BufferedWriter.new
  end
end

# ---- Demonstration ----------------------------------------------------------
ConsoleLoggerFactory.new.log("INFO", "ready")
buf_factory = BufferedLoggerFactory.new
buf_factory.log("WARN", "disk low")
buf_factory.log("ERROR", "disk full")
puts buf_factory.buffered_writer.buffer

# =============================================================================
# EXERCISE 1
#   Add a FileLoggerFactory that writes to a temp file and demonstrate.
# SOLUTION 1:
#   class FileWriter
#     include Writer
#     def initialize(@path : String); end
#     def write(line : String) : Nil
#       File.open(@path, "a") { |f| f.puts line }
#     end
#   end
#   class FileLoggerFactory < LoggerFactory
#     def create_writer(config : Hash(String, String)) : Writer
#       FileWriter.new(config.fetch("path", "/tmp/crystal.log"))
#     end
#   end
#   FileLoggerFactory.new.log("INFO", "to file", {"path" => "/tmp/x.log"})
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Explain why caching the product in the creator (as BufferedLoggerFactory
#   does) is legal even though we call `log` many times.
# SOLUTION 2:
#   Factory Method constrains WHO constructs, not HOW OFTEN. Returning the
#   same cached product is fine as long as it satisfies the Writer contract
#   — callers see only Writer. This makes creators stateful, which is often
#   convenient (connection pools, per-app buffers).
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Refactor to accept an optional "on-write" callback without changing
#   Writer — hint: decorate the writer inside the creator.
# SOLUTION 3:
#   class CallbackWriter
#     include Writer
#     def initialize(@inner : Writer, &@cb : String -> Nil); end
#     def write(line : String) : Nil
#       @inner.write(line)
#       @cb.call(line)
#     end
#   end
#   # In a creator: CallbackWriter.new(StdoutWriter.new) { |l| ... }
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
