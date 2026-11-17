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
#   A document app has a "new doc" button. In the text editor, the button
#   creates a TextDoc; in the sheet editor, it creates a Sheet. The button
#   doesn't change — only the creator does. Factory Method = defer
#   instantiation to subclasses via a factory hook.
#
# SETUP:
#   crystal run 023_factory_method_document.cr
# =============================================================================

# --- Product interface -------------------------------------------------------
module Document
  # Return the result of `title`.
  abstract def title : String
  # Return the result of `open`.
  abstract def open : String
end

# Concrete class `TextDocument`.
class TextDocument
  include Document
  def initialize(@title : String); end
  # Return the result of `title`.
  def title : String; @title; end
  # Return the result of `open`.
  def open : String; "Opening text: #{@title}"; end
end

# Concrete class `SpreadsheetDocument`.
class SpreadsheetDocument
  include Document
  def initialize(@title : String); end
  # Return the result of `title`.
  def title : String; @title; end
  # Return the result of `open`.
  def open : String; "Opening sheet: #{@title}"; end
end

# --- Creator (abstract) ------------------------------------------------------
# Contains business logic that depends only on the product interface.
abstract class DocumentApp
  # The factory method — subclasses decide the concrete product.
  abstract def create_document(title : String) : Document

  # Template method: uses the factory method internally. Notice this code
  # never mentions TextDocument or SpreadsheetDocument — that's the win.
  def new_document(title : String) : String
    doc = create_document(title)
    "App: #{doc.open}"
  end
end

# --- Concrete creators -------------------------------------------------------
class TextApp < DocumentApp
  # Return the result of `create_document`.
  def create_document(title : String) : Document; TextDocument.new(title); end
end

# Concrete class `SheetApp` -- extends DocumentApp.
class SheetApp < DocumentApp
  # Return the result of `create_document`.
  def create_document(title : String) : Document; SpreadsheetDocument.new(title); end
end

# ---- Demonstration ----------------------------------------------------------
apps : Array(DocumentApp) = [TextApp.new, SheetApp.new] of DocumentApp
apps.each { |app| puts app.new_document("Q1 Report") }

# =============================================================================
# EXERCISE 1
#   Add a DrawingApp / DrawingDocument without touching DocumentApp.
# SOLUTION 1:
#   class DrawingDocument
#     include Document
#     def initialize(@title : String); end
#     def title : String; @title; end
#     def open : String; "Opening canvas: #{@title}"; end
#   end
#   class DrawingApp < DocumentApp
#     def create_document(title : String) : Document; DrawingDocument.new(title); end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `preview` template method that also uses create_document, then
#   confirm no concrete class must change.
# SOLUTION 2:
#   In DocumentApp:
#     def preview(title : String) : String
#       "Preview: #{create_document(title).title}"
#     end
#   All apps gain preview instantly — no edits to TextApp/SheetApp.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is this "Open/Closed" while a simple factory with `case` is not?
# SOLUTION 3:
#   A simple factory's `case` must be edited for each new product. Factory
#   Method adds new products via new subclasses of DocumentApp, extending
#   behavior with new code rather than modifying a central switch. The
#   DocumentApp base stays closed; concrete apps are open for extension.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
