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
#   A folder contains files and other folders; you can ask a folder its
#   total size, and it sums everything inside — recursively. Composite =
#   leaf and container share the same interface, so callers treat them
#   uniformly.
#
# SETUP:
#   crystal run 048_composite_filesystem.cr
# =============================================================================

# Module `Node`.
module Node
  # Return the result of `size`.
  abstract def size : Int64
  # Return the human-readable name of this state/object.
  abstract def name : String
  # Render the receiver to a String representation.
  abstract def render(indent : Int32 = 0) : String
end

# Concrete class `FileNode`.
class FileNode
  include Node
  def initialize(@name : String, @size : Int64); end
  # Return the human-readable name of this state/object.
  def name : String; @name; end
  # Return the result of `size`.
  def size : Int64; @size; end
  # Render the receiver to a String representation.
  def render(indent : Int32 = 0) : String
    "#{"  " * indent}- #{@name} (#{@size}B)"
  end
end

# Composite: a directory is itself a Node AND holds other Nodes.
class Directory
  include Node
  def initialize(@name : String); end
  @children = [] of Node

  # Add an element and return self for chaining.
  def add(child : Node) : Directory
    @children << child
    self
  end

  # Return the human-readable name of this state/object.
  def name : String; @name; end
  # Return the result of `size`.
  def size : Int64; @children.sum(&.size); end

  # Render the receiver to a String representation.
  def render(indent : Int32 = 0) : String
    lines = ["#{"  " * indent}+ #{@name}/ (#{size}B)"]
    @children.each { |c| lines << c.render(indent + 1) }
    lines.join('\n')
  end
end

# ---- Demonstration ----------------------------------------------------------
root = Directory.new("root")
root.add(FileNode.new("a.txt", 100))
root.add(FileNode.new("b.txt", 250))
sub = Directory.new("src")
sub.add(FileNode.new("main.cr", 4000))
sub.add(FileNode.new("util.cr", 800))
root.add(sub)
puts root.render
puts "Total: #{root.size}B"

# =============================================================================
# EXERCISE 1
#   Add a SymlinkNode that redirects size to another Node.
# SOLUTION 1:
#   class SymlinkNode
#     include Node
#     def initialize(@name : String, @target : Node); end
#     def name; @name; end
#     def size; @target.size; end
#     def render(indent = 0); "#{"  "indent}-> #{@name} -> #{@target.name}"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `find(predicate : Node -> Bool)` method that traverses uniformly.
# SOLUTION 2:
#   # On FileNode: return [self] if predicate.call(self) else [] of Node
#   # On Directory: results = self-if-match; @children.each { |c| results.concat(c.find(predicate)) }
# =============================================================================

# =============================================================================
# EXERCISE 3
#   How does Composite honor OCP? Give one likely extension.
# SOLUTION 3:
#   Adding a new leaf type (Symlink, ZipArchive) or a new directory type
#   (ReadOnlyDir) requires no edits to existing classes. Only Node's
#   abstract methods must be implemented. Client code that walks the tree
#   keeps working unchanged.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
