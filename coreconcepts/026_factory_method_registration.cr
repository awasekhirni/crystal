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
#   A bakery has a "sign-in book": any new pastry chef can write their name
#   and what they bake. When a customer orders "croissant", the bakery looks
#   up the chef for croissants and asks them to bake. Self-registering
#   factories let each product's creator announce itself once.
#
# SETUP:
#   crystal run 026_factory_method_registration.cr
# =============================================================================

# Module `Exporter`.
module Exporter
  # Return the result of `export`.
  abstract def export(data : String) : String
end

# Concrete class `CsvExporter`.
class CsvExporter
  include Exporter
  # Return the result of `export`.
  def export(data : String) : String; data.split(",").join(";"); end
end

# Concrete class `JsonExporter`.
class JsonExporter
  include Exporter
  # Return the result of `export`.
  def export(data : String) : String; %({"data":"#{data.gsub("\"", "\\\"")}"}); end
end

# Concrete class `XmlExporter`.
class XmlExporter
  include Exporter
  # Return the result of `export`.
  def export(data : String) : String; "<data>#{data}</data>"; end
end

# The "sign-in book." Factories register themselves; the registry is closed
# for modification — extending with a new exporter requires only that the
# new class calls `register`.
class ExporterRegistry
  @@factories = {} of String => Exporter
  @@mutex = Mutex.new

  # Return the result of `self`.
  def self.register(name : String, factory : Exporter) : Nil
    @@mutex.synchronize { @@factories[name.downcase] = factory }
  end

  # Return the result of `self`.
  def self.for(name : String) : Exporter
    @@factories[name.downcase]? || raise "no exporter: #{name}"
  end

  # Return the result of `self`.
  def self.names : Array(String)
    @@factories.keys
  end
end

# Self-registration via class-level initializer. In real Crystal code, a
# plugin often calls this from its own top-level code on load; here we show
# the explicit form for clarity.
ExporterRegistry.register("csv",  CsvExporter.new)
ExporterRegistry.register("json", JsonExporter.new)
ExporterRegistry.register("xml",  XmlExporter.new)

# ---- Demonstration ----------------------------------------------------------
puts ExporterRegistry.names.sort
puts ExporterRegistry.for("csv").export("a,b,c")
puts ExporterRegistry.for("json").export("hello")
puts ExporterRegistry.for("xml").export("hello")

# =============================================================================
# EXERCISE 1
#   Add a YamlExporter that self-registers at the bottom of the file.
# SOLUTION 1:
#   class YamlExporter
#     include Exporter
#     def export(data : String) : String; "---\ndata: #{data}\n"; end
#   end
#   ExporterRegistry.register("yaml", YamlExporter.new)
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `with_exporter(name) { |e| ... }` convenience that raises early.
# SOLUTION 2:
#   def self.with_exporter(name : String, &)
#     yield for(name)
#   end
#   ExporterRegistry.with_exporter("json") { |e| puts e.export("ok") }
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Discuss the thread-safety concern of self-registration.
# SOLUTION 3:
#   Plugin registration mutates shared class-level state, so concurrent
#   registration must be serialized — hence the Mutex above. Reads are safe
#   if we never mutate while reading (or use a copy-on-write hash). Prefer
#   registering at startup, or use a lock-free snapshot for hot paths.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
