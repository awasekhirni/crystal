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
#   Visiting every node in a tree needs a strategy: pre-order (visit node
#   first, then children), in-order (left, node, right — for BSTs sorted),
#   post-order (children then node). Iterators encapsulate those orders.
#
# SETUP:
#   crystal run 073_iterator_tree.cr
# =============================================================================

# --- Node -------------------------------------------------------------------
class Node
  getter value : Int32
  getter children : Array(Node) = [] of Node
  def initialize(@value : Int32); end
  def <<(child : Node) : Node; @children << child; self; end
end

# --- Pre-order iterator (node, then children) ----------------------------
class PreorderIterator
  include Iterator(Int32)

  def initialize(root : Node)
    @stack = [root]
  end

  # Return the result of `next`.
  def next : Iterator::Stop | Int32
    return stop if @stack.empty?
    node = @stack.pop
    # Push children in reverse so leftmost is processed first.
    node.children.reverse_each { |c| @stack << c }
    node.value
  end
end

# --- Post-order iterator (children, then node) ---------------------------
# (Simpler illustrative version; uses a list-based approach.)
class PostorderIterator
  include Iterator(Int32)

  def initialize(root : Node)
    @values = [] of Int32
    visit(root)
  end

  private def visit(n : Node)
    n.children.each { |c| visit(c) }
    @values << n.value
  end

  # Return the result of `next`.
  def next : Iterator::Stop | Int32
    return stop if @values.empty?
    @values.shift
  end
end

# --- Level-order iterator (BFS) ------------------------------------------
class LevelOrderIterator
  include Iterator(Int32)

  def initialize(root : Node)
    @queue = [root]
  end

  # Return the result of `next`.
  def next : Iterator::Stop | Int32
    return stop if @queue.empty?
    node = @queue.shift
    node.children.each { |c| @queue << c }
    node.value
  end
end

# ---- Demonstration ----------------------------------------------------------
root = Node.new(1)
two  = Node.new(2)
three = Node.new(3)
two << Node.new(4) << Node.new(5)
three << Node.new(6)
root << two << three

puts "preorder:    #{PreorderIterator.new(root).to_a}"
puts "postorder:   #{PostorderIterator.new(root).to_a}"
puts "level-order: #{LevelOrderIterator.new(root).to_a}"

# =============================================================================
# EXERCISE 1
#   Implement InorderIterator for a binary tree (left, node, right).
# SOLUTION 1:
#   Recursive helper that appends values; same shape as PostorderIterator
#   but with order: left, node, right.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Combine iterators: chain preorder of two roots.
# SOLUTION 2:
#   a = PreorderIterator.new(root1)
#   b = PreorderIterator.new(root2)
#   a.chain(b).each { |v| print v }   # Iterator provides #chain
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why does materializing into an array (as PostorderIterator does) lose
#   the main iterator benefit?
# SOLUTION 3:
#   Eager materialization uses O(n) memory and blocks early termination
#   (e.g., take(3) still builds all values). A true lazy iterator (stack
#   or state machine) computes on demand and can terminate early. Use the
#   lazy shape for large trees or infinite streams.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
