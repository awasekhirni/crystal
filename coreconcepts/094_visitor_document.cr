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
#   A document is a tree of nodes: paragraphs, headings, images. You want to
#   render to HTML, to Markdown, count words, spell-check — many operations
#   over the same tree. Visitor = add a "walker" per operation without
#   touching the tree classes.
#
# SETUP:
#   crystal run 094_visitor_document.cr
# =============================================================================

# --- Visitor --------------------------------------------------------------
module DocVisitor
  # Visit a Paragraph; return the rendered String.
  abstract def visit_paragraph(p : Paragraph) : String
  # Visit a Heading; return the rendered String.
  abstract def visit_heading(h : Heading) : String
  # Visit an Image; return the rendered String.
  abstract def visit_image(i : Image) : String
end

# --- Element interface ----------------------------------------------------
module DocNode
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  abstract def accept(v : DocVisitor) : String
end

# --- Elements -------------------------------------------------------------
class Paragraph
  include DocNode
  getter text : String
  def initialize(@text : String); end
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  def accept(v : DocVisitor) : String; v.visit_paragraph(self); end
end

# Concrete class `Heading`.
class Heading
  include DocNode
  getter level : Int32, text : String
  def initialize(@level : Int32, @text : String); end
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  def accept(v : DocVisitor) : String; v.visit_heading(self); end
end

# Concrete class `Image`.
class Image
  include DocNode
  getter src : String, alt : String
  def initialize(@src : String, @alt : String); end
  # Dispatch this node to `visitor` (Visitor pattern double dispatch).
  def accept(v : DocVisitor) : String; v.visit_image(self); end
end

# --- Visitors -------------------------------------------------------------
class HtmlVisitor
  include DocVisitor
  # Visit a Paragraph; return the rendered String.
  def visit_paragraph(p) : String; "<p>#{p.text}</p>"; end
  # Visit a Heading; return the rendered String.
  def visit_heading(h) : String; "<h#{h.level}>#{h.text}</h#{h.level}>"; end
  # Visit an Image; return the rendered String.
  def visit_image(i) : String; %(<img src="#{i.src}" alt="#{i.alt}"/>); end
end

# Concrete class `MarkdownVisitor`.
class MarkdownVisitor
  include DocVisitor
  # Visit a Paragraph; return the rendered String.
  def visit_paragraph(p) : String; p.text; end
  # Visit a Heading; return the rendered String.
  def visit_heading(h) : String; "#{"#" * h.level} #{h.text}"; end
  # Visit an Image; return the rendered String.
  def visit_image(i) : String; "![#{i.alt}](#{i.src})"; end
end

# Concrete class `WordCountVisitor`.
class WordCountVisitor
  include DocVisitor
  @total = 0
  # Compute and return the total.
  def total : Int32; @total; end
  # Visit a Paragraph; return the rendered String.
  def visit_paragraph(p) : String; @total += p.text.split.size; ""; end
  # Visit a Heading; return the rendered String.
  def visit_heading(h) : String; @total += h.text.split.size; ""; end
  # Visit an Image; return the rendered String.
  def visit_image(i) : String; ""; end
end

# ---- Demonstration ----------------------------------------------------------
# The `of DocNode` annotation forces the array to the abstract type rather
# than the inferred union `Array(Heading | Image | Paragraph)`.
doc : Array(DocNode) = [
  Heading.new(1, "Welcome"),
  Paragraph.new("Hello readers."),
  Image.new("/logo.png", "Logo"),
] of DocNode

puts doc.map(&.accept(HtmlVisitor.new)).join("\n")
puts
puts doc.map(&.accept(MarkdownVisitor.new)).join("\n\n")

counter = WordCountVisitor.new
doc.each { |n| n.accept(counter) }
puts "\nWord count: #{counter.total}"

# =============================================================================
# EXERCISE 1
#   Add a "PlainTextVisitor" that strips markup.
# SOLUTION 1:
#   class PlainTextVisitor
#     include DocVisitor
#     def visit_paragraph(p); p.text; end
#     def visit_heading(h); h.text.upcase; end
#     def visit_image(i); "[image: #{i.alt}]"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   A visitor that finds all images by URL.
# SOLUTION 2:
#   class ImageFinder
#     include DocVisitor
#     getter results = [] of String
#     def visit_paragraph(_); ""; end
#     def visit_heading(_); ""; end
#     def visit_image(i); @results << i.src; ""; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare extending the tree (new node type) vs extending behaviors
#   (new visitor). Which direction is cheaper?
# SOLUTION 3:
#   Adding a visitor is cheap — new class, no changes to nodes.
#   Adding a node type is expensive — every visitor must implement a
#   visit_x method, or the compile fails. That's why Visitor shines when
#   nodes are stable but operations grow (compilers, renderers).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
