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
#   Importing data is always: open source → parse → validate → save →
#   close. The steps vary per source (CSV, JSON, XML) but the order is
#   identical. Template Method = fix the order, vary the steps.
#
# SETUP:
#   crystal run 092_template_method_data_import.cr
# =============================================================================

# Abstract class `Importer`.
abstract class Importer
  # Template method: fixed sequence of steps.
  def run(source : String) : Array(Hash(String, String))
    raw = read(source)
    rows = parse(raw)
    valid = rows.select { |r| valid_row?(r) }
    save(valid)
    valid
  ensure
    close
  end

  # Default validation: non-empty.
  def valid_row?(row : Hash(String, String)) : Bool
    !row.empty?
  end

  # Default cleanup (no-op).
  def close : Nil; end

  # Read and return the source as a String.
  abstract def read(source : String) : String
  # Parse `raw` into a list of typed rows.
  abstract def parse(raw : String) : Array(Hash(String, String))
  # Persist the rows.  Returns Nil.
  abstract def save(rows : Array(Hash(String, String))) : Nil
end

# --- CSV importer --------------------------------------------------------
class CsvImporter < Importer
  # Read and return the source as a String.
  def read(source : String) : String
    "name,age\nAlice,30\n,\nBob,25"
  end

  # Parse `raw` into a list of typed rows.
  def parse(raw : String) : Array(Hash(String, String))
    lines = raw.lines
    headers = lines.first.split(',')
    lines[1..].map do |line|
      values = line.split(',')
      headers.zip(values).to_h
    end
  end

  # Persist the rows.  Returns Nil.
  def save(rows : Array(Hash(String, String))) : Nil
    puts "saving #{rows.size} CSV rows"
  end
end

# --- JSON importer (toy) --------------------------------------------------
class JsonImporter < Importer
  # Read and return the source as a String.
  def read(source : String) : String
    %([{"name":"Carol","age":"40"},{"name":"","age":""}])
  end

  # Parse `raw` into a list of typed rows.
  def parse(raw : String) : Array(Hash(String, String))
    # Toy: not a real JSON parser.  Two fixes vs. the original:
    #   1. Regex `(.?)` matches zero-or-one of any char -- useless.  Use
    #      `(.*?)` (non-greedy any chars) so each capture spans a value.
    #   2. `do |(m)|` destructures the MatchData (yielding the full match
    #      as a String), so `m[1]` returns a Char.  Use `do |m|` so `m` is
    #      the Regex::MatchData and `m[1]` is the first capture group String.
    raw.scan(/\{"name":"(.*?)","age":"(.*?)"\}/).map do |m|
      {"name" => m[1], "age" => m[2]}
    end
  end

  # Return true if `row` should be kept.
  def valid_row?(row : Hash(String, String)) : Bool
    super && !row["name"].empty?
  end

  # Persist the rows.  Returns Nil.
  def save(rows : Array(Hash(String, String))) : Nil
    puts "saving #{rows.size} JSON rows"
  end
end

# ---- Demonstration ----------------------------------------------------------
puts CsvImporter.new.run("anything").inspect
puts JsonImporter.new.run("anything").inspect

# =============================================================================
# EXERCISE 1
#   Add an XmlImporter.
# SOLUTION 1:
#   class XmlImporter < Importer
#     def read(src); "<rows><row name='A' age='1'/></rows>"; end
#     def parse(raw); [{"name" => "A", "age" => "1"}]; end
#     def save(rows); puts "saved #{rows.size} XML rows"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "dry_run" flag that skips `save`.
# SOLUTION 2:
#   def initialize(@dry_run = false); end
#   def run(source)
#     raw = read(source); rows = parse(raw); valid = rows.select { |r| valid_row?(r) }
#     save(valid) unless @dry_run
#     valid
#   ensure
#     close
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is `ensure close` correct here rather than at the end of `run`?
# SOLUTION 3:
#   `ensure` guarantees cleanup runs even if parse/save raise. Without it, an
#   exception between read and close leaks resources (file handles, network).
#   This is a critical Template Method benefit: the skeleton gets cleanup
#   right once, for all subclasses.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
