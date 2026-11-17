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
#   Your app's logs go to several places: console, file, bug tracker. A
#   message goes to the first "logger" it matches by severity. The chain
#   stops once handled (or continues if the handler is a "pass-through").
#
# SETUP:
#   crystal run 068_chain_of_responsibility_logging.cr
# =============================================================================

# Severity as a simple enum.
enum Severity
  Debug
  Info
  Warn
  Error
end

# Abstract class `LogHandler`.
abstract class LogHandler
  @next : LogHandler?
  def initialize(@min : Severity); end
  # Return the result of `chain`.
  def chain(n : LogHandler?) : LogHandler?; @next = n; n; end

  # Wire up `ws` for the chat session (lifecycle callbacks).
  def handle(sev : Severity, msg : String) : Bool
    if sev >= @min && write(sev, msg)
      true
    elsif @next
      @next.not_nil!.handle(sev, msg)
    else
      false
    end
  end

  # Append `data` to the underlying buffer/stream.  Returns Nil.
  abstract def write(sev : Severity, msg : String) : Bool
end

# Concrete class `ConsoleHandler` -- extends LogHandler.
class ConsoleHandler < LogHandler
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(sev : Severity, msg : String) : Bool
    puts "[console #{sev}] #{msg}"
    true
  end
end

# Concrete class `FileHandler` -- extends LogHandler.
class FileHandler < LogHandler
  def initialize(@min : Severity, @path : String); super(@min); end
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(sev : Severity, msg : String) : Bool
    File.open(@path, "a") { |f| f.puts "#{sev}: #{msg}" }
    true
  end
end

# Page an on-call engineer for Error only. Returns false to keep chain going.
class PageHandler < LogHandler
  # Append `data` to the underlying buffer/stream.  Returns Nil.
  def write(sev : Severity, msg : String) : Bool
    if sev == Severity::Error
      puts "[page on-call] #{msg}"
      true
    else
      false  # let the next handler try
    end
  end
end

# --- Build chain ------------------------------------------------------------
debug = ConsoleHandler.new(Severity::Debug)
file  = FileHandler.new(Severity::Warn, "/tmp/coh_068.log")
page  = PageHandler.new(Severity::Error)
debug.chain(file).not_nil!.chain(page)

# ---- Demonstration ----------------------------------------------------------
[Severity::Debug, Severity::Info, Severity::Warn, Severity::Error].each do |sev|
  handled = debug.handle(sev, "sample #{sev}")
  puts "  handled=#{handled}"
end

# =============================================================================
# EXERCISE 1
#   Change PageHandler to also forward after paging (fan-out).
# SOLUTION 1:
#   class PageAndForward < LogHandler
#     def write(sev, msg)
#       # page if error, always return false to forward
#       puts "[page] #{msg}" if sev == Severity::Error
#       false
#     end
#   end
#   # Note: with write returning false, the chain continues. This is CoR in
#   # "fan-out" mode. If you need fan-out with all branches, use Observer.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Is the chain "stop on first handler" or "try all"? Which should you pick?
# SOLUTION 2:
#   Both are valid CoR variants. Stop-on-first is common for routing
#   (401, 404). Fan-out (all handlers can act) makes more sense for logging
#   and telemetry. Choose based on whether handling is exclusive or shared.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   What if PageHandler throws? Design a mitigation.
# SOLUTION 3:
#   Wrap the handler call in begin/rescue inside `handle`, log the failure
#   (in a local fallback that can't fail — e.g., STDERR.puts), and let the
#   chain continue. Robust chains must not let one flaky handler drop every
#   subsequent log.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
