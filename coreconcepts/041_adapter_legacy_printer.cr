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
#   You have a modern USB-C laptop, but the hotel TV only has HDMI. You use
#   an adapter dongle. Code is the same: a new system needs to call an old
#   API, and an Adapter bridges the mismatch without changing either side.
#
# SETUP:
#   crystal run 041_adapter_legacy_printer.cr
# =============================================================================

# --- The interface our app depends on (modern) ------------------------------
module Printer
  # Return the result of `print_document`.
  abstract def print_document(text : String) : String
end

# --- Legacy system we cannot modify ----------------------------------------
class LegacyLinePrinter
  # Return the result of `print_lines`.
  def print_lines(lines : Array(String)) : String
    "LEGACY> " + lines.join("\\nLEGACY> ")
  end
end

# --- The Adapter: implements the modern interface, delegates to the legacy --
class LegacyPrinterAdapter
  include Printer
  def initialize(@legacy : LegacyLinePrinter); end

  # Return the result of `print_document`.
  def print_document(text : String) : String
    # Adapt the message format: split into lines the legacy printer wants.
    @legacy.print_lines(text.split('\n'))
  end
end

# --- Client: only knows Printer --------------------------------------------
def run_report(printer : Printer) : Nil
  puts printer.print_document("Hello\nWorld")
end

# ---- Demonstration ----------------------------------------------------------
run_report(LegacyPrinterAdapter.new(LegacyLinePrinter.new))

# =============================================================================
# EXERCISE 1
#   Adapt an even older "character-by-character" printer into Printer.
# SOLUTION 1:
#   class CharPrinter
#     def put_char(c : Char) : Nil; print c; end
#   end
#   class CharPrinterAdapter
#     include Printer
#     def initialize(@p : CharPrinter); end
#     def print_document(text : String) : String
#       text.each_char { |c| @p.put_char(c) }
#       "" # (or capture via IO if you want a String)
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a timestamp prefix in the adapter — allowed because it's OUR class.
# SOLUTION 2:
#   def print_document(text : String) : String
#     @legacy.print_lines(["[#{Time.utc}]"] + text.split('\n'))
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is the adapter the "right" place for this transformation rather than
#   the client or the legacy class?
# SOLUTION 3:
#   The client should stay abstract (Printer only). The legacy class should
#   stay untouched (we can't modify 3rd-party code). The Adapter is the one
#   place where both contracts meet; putting translation there keeps every
#   other class single-purpose (SRP) and open for swapping implementations.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
