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
#   A small real-world-ish application that uses several structural patterns
#   together: a Facade orchestrates, a Composite represents a config tree,
#   a Decorator adds caching, an Adapter bridges a legacy format, a Proxy
#   controls access, and Flyweight caches repeated values. This is how
#   structural patterns tend to appear in real code — layered.
#
# SETUP:
#   crystal run 065_structural_capstone.cr
# =============================================================================

# --- Composite: config nodes ----------------------------------------------
module ConfigNode
  # Return the configured value for `key`, or Nil if absent.
  abstract def value_for(key : String) : String?
end

# Concrete class `LeafConfig`.
class LeafConfig
  include ConfigNode
  def initialize(@key : String, @value : String); end
  # Return the configured value for `key`, or Nil if absent.
  def value_for(key : String) : String?
    key == @key ? @value : nil
  end
end

# Concrete class `SectionConfig`.
class SectionConfig
  include ConfigNode
  def initialize(@name : String); end
  @children = [] of ConfigNode
  # Add an element and return self for chaining.
  def add(c : ConfigNode) : SectionConfig; @children << c; self; end
  # Return the configured value for `key`, or Nil if absent.
  def value_for(key : String) : String?
    # Supports "section.key" paths, or top-level leaf.
    if key.starts_with?("#{@name}.")
      sub = key[@name.size + 1..]
      @children.each do |c|
        v = c.value_for(sub)
        return v if v
      end
      nil
    else
      @children.each do |c|
        v = c.value_for(key)
        return v if v
      end
      nil
    end
  end
end

# --- Adapter: legacy INI file to ConfigNode tree --------------------------
class IniFile
  def initialize(@text : String); end
  # Return the result of `raw_lines`.
  def raw_lines : Array(String); @text.lines; end
end

# Concrete class `IniToConfigAdapter`.
class IniToConfigAdapter
  include ConfigNode

  def initialize(legacy : IniFile)
    @root = SectionConfig.new("root")
    current : SectionConfig = @root
    legacy.raw_lines.each do |line|
      line = line.strip
      next if line.empty? || line.starts_with?('#')
      if line.starts_with?('[') && line.ends_with?(']')
        section = SectionConfig.new(line[1..-2])
        @root.add(section)
        current = section
      elsif (idx = line.index('='))
        current.add(LeafConfig.new(line[0, idx].strip, line[idx + 1..].strip))
      end
    end
  end

  # Return the configured value for `key`, or Nil if absent.
  def value_for(key : String) : String?
    @root.value_for(key)
  end
end

# --- Flyweight: cache values by key --------------------------------------
# The cache stores `String?` (not `String`) so a missing-key lookup that
# returns nil from the underlying source can be negatively cached too,
# avoiding repeated lookups for the same missing key.  The `fetch` return
# type is correspondingly `String?`.
class ValueCache
  @cache = {} of String => String?
  # Return the cached value for `key`, or compute it via the block.
  def fetch(key : String, &) : String?
    @cache[key]? || (@cache[key] = yield)
  end
end

# --- Proxy: access control around config ---------------------------------
class ReadOnlyProxy
  include ConfigNode
  def initialize(@inner : ConfigNode); end
  # Return the configured value for `key`, or Nil if absent.
  def value_for(key : String) : String?
    @inner.value_for(key)
  end
end

# --- Facade: user-facing entry -------------------------------------------
class ConfigFacade
  # Instance-variable type annotations must live at the class level in
  # Crystal, not inside `initialize`.  Declare the type once here, then
  # assign in the constructor.
  @node : ConfigNode
  @cache : ValueCache

  def initialize(ini_text : String, allowed : Bool)
    base = IniToConfigAdapter.new(IniFile.new(ini_text))
    @cache = ValueCache.new
    @node = allowed ? ReadOnlyProxy.new(base) : ReadOnlyProxy.new(SectionConfig.new("empty"))
  end

  # Look up `key`; returns the value or Nil if absent.
  def get(key : String) : String?
    @cache.fetch(key) { @node.value_for(key) }
  end
end

# ---- Demonstration ----------------------------------------------------------
ini = <<-INI
  # sample
  [server]
  host = localhost
  port = 8080
  [db]
  host = db.local
  port = 5432
INI

facade = ConfigFacade.new(ini, true)
puts facade.get("server.host")   # localhost
puts facade.get("server.port")   # 8080
puts facade.get("db.host")       # db.local
puts facade.get("missing").inspect

# =============================================================================
# EXERCISE 1
#   Add mutation: an "admin" facade that allows setting values by rebuilding
#   the tree. Discuss why read-only is safer as default.
# SOLUTION 1:
#   Extend SectionConfig with `set(key, value)` that walks sections and
#   replaces leaves. Admin facade exposes `set`; non-admin doesn't. Default
#   read-only prevents accidental destructive writes on shared config.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a Decorator around ConfigNode that overrides one key (staging).
# SOLUTION 2:
#   class OverrideDecorator
#     include ConfigNode
#     def initialize(@inner : ConfigNode, @key : String, @value : String); end
#     def value_for(key : String)
#       key == @key ? @value : @inner.value_for(key)
#     end
#   end
#   # Compose as OverrideDecorator.new(base, "server.host", "stage.host")
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Map each class here to a Structural pattern and one sentence each.
# SOLUTION 3:
#   - Composite: SectionConfig & LeafConfig share ConfigNode.
#   - Adapter: IniToConfigAdapter bridges raw INI to ConfigNode.
#   - Flyweight: ValueCache shares String values across reads.
#   - Proxy: ReadOnlyProxy stands in for the real tree with a policy.
#   - Facade: ConfigFacade orchestrates adapter+proxy+cache for callers.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
